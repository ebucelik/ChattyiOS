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
        var postState: Loadable<Post>

        init(postState: Loadable<Post> = .none) {
            self.postState = postState
        }
    }

    enum Action {
        case fetchPost
        case postStateChanged(Loadable<Post>)
    }

    @Dependency(\.postService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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
        }
    }
}
