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
        var ownAccount: Account
        var subscriptionRequestsState: Loadable<[Account]>

        init(ownAccount: Account,
             subscriptionRequestsState: Loadable<[Account]> = .none) {
            self.ownAccount = ownAccount
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
            return .run { [ownAccount = state.ownAccount] send in
                await send(.subscriptionRequestsStateChanged(.loading))

                let subscriptionRequestAccounts = try await service.getSubscriptionRequestsBy(id: ownAccount.id)

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
            return .run { [ownAccount = state.ownAccount] send in
                let subscriber = Subscriber(
                    userId: subscriberAccount.id,
                    subscribedUserId: ownAccount.id,
                    accepted: true
                )

                _ = try await service.acceptSubscription(subscriber: subscriber)

                OneSignalClient.shared.sendPush(
                    with: "@\(ownAccount.username) accepted your subscription.",
                    title: "",
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
            return .run { [ownAccount = state.ownAccount] send in
                let subscriber = Subscriber(
                    userId: subscriberId,
                    subscribedUserId: ownAccount.id
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
