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
        var otherAccountId: Int?
        var ownAccountId: Int?
        var postState: Loadable<Post>
        var deletePostState: Loadable<Message>

        var postDate: String = ""

        @BindingState
        var showAlert: Bool = false
        @BindingState
        var showDeleteAlert: Bool = false

        var postLiked: Bool = false

        var isFeedView: Bool

        var isOtherAccount: Bool {
            otherAccountId != nil
        }

        init(otherAccountId: Int?,
             ownAccountId: Int?,
             postState: Loadable<Post> = .none,
             deletePostState: Loadable<Message> = .none,
             isFeedView: Bool = false) {
            self.otherAccountId = otherAccountId
            self.ownAccountId = ownAccountId
            self.postState = postState
            self.deletePostState = deletePostState
            self.isFeedView = isFeedView

            if case let .loaded(post) = postState {
                self.postDate = post.timestamp.toStringDate
                self.postLiked = post.likedByYou ?? false
            }
        }
    }

    enum Action: BindableAction, Equatable {
        case fetchPost
        case postStateChanged(Loadable<Post>)

        case setPostDate(Double)

        case showDeleteAlert
        case deletePost
        case deletePostStateChanged(Loadable<Message>)

        case likePost
        case postLiked

        case removeLikeFromPost
        case likeRemoved

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

                var userId = 0

                if let otherAccountId = state.otherAccountId {
                    userId = otherAccountId
                } else if let ownAccountId = state.ownAccountId {
                    userId = ownAccountId
                }

                guard case let .loaded(post) = state.postState else { return .none }

                return .task { [userId = userId] in
                    let post = try await self.service.fetchPostBy(
                        id: post.id,
                        userId: userId
                    )

                    return .postStateChanged(.loaded(post))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .postStateChanged(.error(apiError))
                    } else {
                        return .postStateChanged(.error(.error(error)))
                    }
                }
                .prepend(.postStateChanged(.loading))
                .eraseToEffect()

            case let .postStateChanged(postState):
                state.postState = postState

                if case let .loaded(post) = postState {
                    return .send(.setPostDate(post.timestamp))
                }

                return .none

            case let .setPostDate(timestamp):
                state.postDate = timestamp.toStringDate

                return .none

            case .showDeleteAlert:
                state.showDeleteAlert.toggle()

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

            case .likePost:

                if state.postLiked { return .none }

                var userId = 0

                if let otherAccountId = state.otherAccountId {
                    userId = otherAccountId
                } else if let ownAccountId = state.ownAccountId {
                    userId = ownAccountId
                }

                guard case let .loaded(post) = state.postState else { return .none }

                return .concatenate(
                    [
                        .task { [userId = userId] in
                            _ = try await self.service.saveLikeFromAccountToPost(postId: post.id, userId: userId)

                            return .fetchPost
                        },
                        .send(.postLiked)
                    ]
                )

            case .postLiked:
                state.postLiked = true

                return .none

            case .removeLikeFromPost:

                var userId = 0

                if let otherAccountId = state.otherAccountId {
                    userId = otherAccountId
                } else if let ownAccountId = state.ownAccountId {
                    userId = ownAccountId
                }

                guard case let .loaded(post) = state.postState else { return .none }

                return .concatenate(
                    [
                        .task { [userId = userId] in
                            _ = try await self.service.removeLikeFromAccountToPost(postId: post.id, userId: userId)

                            return .fetchPost
                        },
                        .send(.likeRemoved)
                    ]
                )

            case .likeRemoved:
                state.postLiked = false

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
