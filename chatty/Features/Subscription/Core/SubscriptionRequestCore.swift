//
//  SubscriptionRequestCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.01.23.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

struct SubscriptionRequestCore: ReducerProtocol {

    struct State: Equatable {
        var ownAccountId: Int
        var subscriptionRequestsState: Loadable<[Account]>

        init(ownAccountId: Int,
             subscriptionRequestsState: Loadable<[Account]> = .none) {
            self.ownAccountId = ownAccountId
            self.subscriptionRequestsState = subscriptionRequestsState
        }
    }

    enum Action: Equatable {
        case fetchSubscriptionRequests
        case subscriptionRequestsStateChanged(Loadable<[Account]>)
    }

    @Dependency(\.subscriberService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchSubscriptionRequests:
            return .task { [ownAccountId = state.ownAccountId] in
                let subscriptionRequestAccounts = try await service.getSubscriptionRequestsBy(id: ownAccountId)

                return .subscriptionRequestsStateChanged(.loaded(subscriptionRequestAccounts))
            } catch: { error in
                if let apiError = error as? APIError {
                    return .subscriptionRequestsStateChanged(.error(apiError))
                } else {
                    return .subscriptionRequestsStateChanged(.error(.error(error)))
                }
            }
            .debounce(id: DebounceId(), for: 1, scheduler: self.mainScheduler)
            .prepend(.subscriptionRequestsStateChanged(.loading))
            .eraseToEffect()

        case .subscriptionRequestsStateChanged(let subscriptionRequestsState):
            state.subscriptionRequestsState = subscriptionRequestsState

            return .none
        }
    }
}
