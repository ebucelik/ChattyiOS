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

class FeedCore: ReducerProtocol {
    struct State: Equatable {
        var account: Account?
        var limit: Int
        var postsState: Loadable<[Post]>
        var posts: [Post] = [.mock, .mock, .mock, .mock, .mock, .mock, .mock, .mock]
        var postsComplete: Bool = false

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
    }

    @Dependency(\.feedPostsService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceID: Hashable { }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onScroll:
                return .merge(
                    [
                        .task { .increaseLimit },
                        .task { .loadPosts }
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

                return .task { [limit = state.limit] in
                    let posts = try await self.service.getFeedPosts(
                        for: account.id,
                        limit: limit
                    )

                    return .postsStateChanged(.loaded(posts))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .postsStateChanged(.error(apiError))
                    } else {
                        return .postsStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: DebounceID(), for: 2, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.postsStateChanged(.loading))
                .eraseToEffect()

            case let .postsStateChanged(postsState):
                state.postsState = postsState

                if case let .loaded(posts) = postsState {
                    state.postsComplete = state.posts.count == posts.count
                    state.posts = posts
                }

                return .none
            }
        }
    }
}
