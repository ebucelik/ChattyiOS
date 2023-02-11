//
//  PostCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 05.02.23.
//

import Foundation
import ComposableArchitecture
import SwiftHelper

class PostCore: ReducerProtocol {

    struct State: Equatable {
        var isOtherAccount: Bool
        var postState: Loadable<Post>
        var deletePostState: Loadable<Message>

        @BindableState var showAlert: Bool = false

        init(isOtherAccount: Bool,
             postState: Loadable<Post> = .none,
             deletePostState: Loadable<Message> = .none) {
            self.isOtherAccount = isOtherAccount
            self.postState = postState
            self.deletePostState = deletePostState
        }
    }

    enum Action: BindableAction, Equatable {
        case fetchPost
        case postStateChanged(Loadable<Post>)

        case deletePost
        case deletePostStateChanged(Loadable<Message>)

        case showAlert
        case binding(BindingAction<State>)
    }

    @Dependency(\.postService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .fetchPost:

                guard case let .loaded(post) = state.postState else { return .none }

                return .task {
                    let post = try await self.service.fetchPostBy(id: post.id)

                    return .postStateChanged(.loaded(post))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .postStateChanged(.error(apiError))
                    } else {
                        return .postStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: DebounceId(), for: 1, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.postStateChanged(.loading))
                .eraseToEffect()

            case let .postStateChanged(postState):
                state.postState = postState

                return .none

            case .deletePost:

                guard case let .loaded(post) = state.postState else { return .none }

                return .task {
                    let message = try await self.service.deletePost(id: post.id)

                    return .deletePostStateChanged(.loaded(message))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .deletePostStateChanged(.error(apiError))
                    } else {
                        return .deletePostStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: DebounceId(), for: 1, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.deletePostStateChanged(.loading))
                .eraseToEffect()

            case let .deletePostStateChanged(deletePostState):
                state.deletePostState = deletePostState

                return .none

            case .showAlert:
                state.showAlert.toggle()

                return .none

            case .binding:
                return .none
            }
        }
    }
}
