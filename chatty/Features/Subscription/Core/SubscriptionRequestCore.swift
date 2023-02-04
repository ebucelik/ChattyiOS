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

        case acceptSubscription(Int)
        case subscriptionAccepted
        case declineSubscription(Int)
        case subscriptionDeclined
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

        case let .acceptSubscription(subscriberId):
            return .task { [ownAccountId = state.ownAccountId] in
                let subscriber = Subscriber(
                    userId: subscriberId,
                    subscribedUserId: ownAccountId,
                    accepted: true
                )

                _ = try await service.acceptSubscription(subscriber: subscriber)

                return .subscriptionAccepted
            } catch: { error in
                if let apiError = error as? APIError {
                    return .subscriptionRequestsStateChanged(.error(apiError))
                } else {
                    return .subscriptionRequestsStateChanged(.error(.error(error)))
                }
            }

        case let .declineSubscription(subscriberId):
            return .task { [ownAccountId = state.ownAccountId] in
                let subscriber = Subscriber(
                    userId: subscriberId,
                    subscribedUserId: ownAccountId
                )

                _ = try await service.declineSubscription(subscriber: subscriber)

                return .subscriptionDeclined
            } catch: { error in
                if let apiError = error as? APIError {
                    return .subscriptionRequestsStateChanged(.error(apiError))
                } else {
                    return .subscriptionRequestsStateChanged(.error(.error(error)))
                }
            }

        case .subscriptionAccepted, .subscriptionDeclined:
            return .task { .fetchSubscriptionRequests }
        }
    }
}
