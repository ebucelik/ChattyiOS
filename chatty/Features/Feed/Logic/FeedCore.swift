//
//  FeedCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.07.22.
//

import Foundation

import SwiftHelper
import ComposableArchitecture
import Combine

class FeedCore: Reducer {
    struct State: Equatable {
        var account: Account?
        var limit: Int
        var postsState: Loadable<[Post]>
        var posts: [Post] = [.mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock]
        var postsComplete: Bool = false

        var postsStates = IdentifiedArrayOf<PostCore.State>()

        var username: String {
            guard let account = account else { return "" }

            return account.username
        }

        init(account: Account? = nil,
             limit: Int = 0,
             postsState: Loadable<[Post]> = .none) {
            self.account = account
            self.limit = limit
            self.postsState = postsState
        }
    }

    enum Action: Equatable {
        case onScroll
        case increaseLimit
        case loadPosts
        case postsStateChanged(Loadable<[Post]>)
        case post(id: PostCore.State.ID, action: PostCore.Action)
    }

    @Dependency(\.feedPostsService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceID: Hashable { }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onScroll:
                return .concatenate(
                    [
                        .send(.increaseLimit),
                        .send(.loadPosts)
                    ]
                )
                
            case .increaseLimit:
                if !state.postsComplete {
                    state.limit += 2
                }

                return .none

            case .loadPosts:

                guard let account = state.account else {
                    return .send(.postsStateChanged(.error(.notFound)))
                }

                return .run { [limit = state.limit] send in
                    await send(.postsStateChanged(.loading))

                    let posts = try await self.service.getFeedPosts(
                        for: account.id,
                        limit: limit
                    )

                    await send(.postsStateChanged(.loaded(posts)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.postsStateChanged(.error(apiError)))
                    } else {
                        await send(.postsStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: DebounceID(), for: 0.4, scheduler: self.mainScheduler)

            case let .postsStateChanged(postsState):
                state.postsState = postsState

                if case let .loaded(posts) = postsState {
                    state.postsComplete = state.posts.count == posts.count
                    state.posts = posts
                    state.postsStates = IdentifiedArray(
                        uniqueElements: posts.compactMap {
                            PostCore.State(
                                otherAccountId: nil,
                                ownAccountId: state.account?.id,
                                postState: .loaded($0),
                                isFeedView: true
                            )
                        }
                    )
                }

                return .none

            case .post:
                return .none
            }
        }
        .forEach(\.postsStates, action: /Action.post(id:action:)) {
            PostCore()
        }
    }
}
