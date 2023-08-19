//
//  PostCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 05.02.23.
//

import Foundation
import ComposableArchitecture
import SwiftHelper

class PostCore: Reducer {

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
                self.postLiked = post.likedByYou
            }
        }
    }

    enum Action: Equatable {
        case postStateChanged(Loadable<Post>)
        case deletePostStateChanged(Loadable<Message>)
        case view(View)

        public enum View: BindableAction, Equatable {
            case fetchPost

            case setPostDate(Double)

            case showDeleteAlert
            case deletePost

            case likePost
            case postLiked

            case removeLikeFromPost
            case likeRemoved

            case showAlert
            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.postService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .view(.fetchPost):

                var userId = 0

                if let otherAccountId = state.otherAccountId {
                    userId = otherAccountId
                } else if let ownAccountId = state.ownAccountId {
                    userId = ownAccountId
                }

                guard case let .loaded(post) = state.postState else { return .none }

                return .run { [userId = userId] send in
                    await send(.postStateChanged(.loading))

                    let post = try await self.service.fetchPostBy(
                        id: post.id,
                        userId: userId
                    )

                    await send(.postStateChanged(.loaded(post)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.postStateChanged(.error(apiError)))
                    } else {
                        await send(.postStateChanged(.error(.error(error))))
                    }
                }

            case let .postStateChanged(postState):
                state.postState = postState

                if case let .loaded(post) = postState {
                    return .send(.view(.setPostDate(post.timestamp)))
                }

                return .none

            case let .view(.setPostDate(timestamp)):
                state.postDate = timestamp.toStringDate

                return .none

            case .view(.showDeleteAlert):
                state.showDeleteAlert.toggle()

                return .none

            case .view(.deletePost):

                guard case let .loaded(post) = state.postState else { return .none }

                return .run { send in
                    await send(.deletePostStateChanged(.loading))

                    let message = try await self.service.deletePost(id: post.id)

                    await send(.deletePostStateChanged(.loaded(message)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.deletePostStateChanged(.error(apiError)))
                    } else {
                        await send(.deletePostStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: DebounceId(), for: 0.4, scheduler: self.mainScheduler)

            case let .deletePostStateChanged(deletePostState):
                state.deletePostState = deletePostState

                return .none

            case .view(.likePost):

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
                        .run { [userId = userId] send in
                            _ = try await self.service.saveLikeFromAccountToPost(postId: post.id, userId: userId)

                            await send(.view(.fetchPost))
                        },
                        .send(.view(.postLiked))
                    ]
                )

            case .view(.postLiked):
                state.postLiked = true

                return .none

            case .view(.removeLikeFromPost):

                var userId = 0

                if let otherAccountId = state.otherAccountId {
                    userId = otherAccountId
                } else if let ownAccountId = state.ownAccountId {
                    userId = ownAccountId
                }

                guard case let .loaded(post) = state.postState else { return .none }

                return .concatenate(
                    [
                        .run { [userId = userId] send in
                            _ = try await self.service.removeLikeFromAccountToPost(postId: post.id, userId: userId)

                            await send(.view(.fetchPost))
                        },
                        .send(.view(.likeRemoved))
                    ]
                )

            case .view(.likeRemoved):
                state.postLiked = false

                return .none

            case .view(.showAlert):
                state.showAlert.toggle()

                return .none

            case .view(.binding):
                return .none

            case .view:
                return .none
            }
        }
    }
}
