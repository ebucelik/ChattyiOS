//
//  SubscriptionRequestCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.01.23.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

struct SubscriptionRequestCore: Reducer {

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

        case acceptSubscription(Account)
        case subscriptionAccepted
        case declineSubscription(Int)
        case subscriptionDeclined
    }

    @Dependency(\.subscriberService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchSubscriptionRequests:
            return .run { [ownAccountId = state.ownAccountId] send in
                await send(.subscriptionRequestsStateChanged(.loading))

                let subscriptionRequestAccounts = try await service.getSubscriptionRequestsBy(id: ownAccountId)

                await send(.subscriptionRequestsStateChanged(.loaded(subscriptionRequestAccounts)))
            } catch: { error, send in
                if let apiError = error as? APIError {
                    await send(.subscriptionRequestsStateChanged(.error(apiError)))
                } else {
                    await send(.subscriptionRequestsStateChanged(.error(.error(error))))
                }
            }
            .debounce(id: DebounceId(), for: 0.4, scheduler: self.mainScheduler)

        case .subscriptionRequestsStateChanged(let subscriptionRequestsState):
            state.subscriptionRequestsState = subscriptionRequestsState

            return .none

        case let .acceptSubscription(subscriberAccount):
            return .run { [ownAccountId = state.ownAccountId] send in
                let subscriber = Subscriber(
                    userId: subscriberAccount.id,
                    subscribedUserId: ownAccountId,
                    accepted: true
                )

                _ = try await service.acceptSubscription(subscriber: subscriber)

                OneSignalClient.shared.sendPush(
                    with: "@\(subscriberAccount.username) accepted your subscription.",
                    title: "Chatty",
                    accountId: subscriberAccount.id
                )

                await send(.subscriptionAccepted)
            } catch: { error, send in
                if let apiError = error as? APIError {
                    await send(.subscriptionRequestsStateChanged(.error(apiError)))
                } else {
                    await send(.subscriptionRequestsStateChanged(.error(.error(error))))
                }
            }

        case let .declineSubscription(subscriberId):
            return .run { [ownAccountId = state.ownAccountId] send in
                let subscriber = Subscriber(
                    userId: subscriberId,
                    subscribedUserId: ownAccountId
                )

                _ = try await service.declineSubscription(subscriber: subscriber)

                await send(.subscriptionDeclined)
            } catch: { error, send in
                if let apiError = error as? APIError {
                    await send(.subscriptionRequestsStateChanged(.error(apiError)))
                } else {
                    await send(.subscriptionRequestsStateChanged(.error(.error(error))))
                }
            }

        case .subscriptionAccepted, .subscriptionDeclined:
            return .send(.fetchSubscriptionRequests)
        }
    }
}
