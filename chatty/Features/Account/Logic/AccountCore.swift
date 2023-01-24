//
//  AccountCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 29.12.22.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

class AccountCore: ReducerProtocol {

    struct State: Equatable {
        var ownAccountId: Int?
        var accountState: Loadable<Account>
        var subscriberState: Loadable<[Account]>
        var subscribedState: Loadable<[Account]>
        var subscribeState: Loadable<Subscriber>
        var subscriptionInfoState: Loadable<SubscriptionInfo>

        var isOtherAccount: Bool {
            ownAccountId != nil
        }

        init(ownAccountId: Int? = nil,
             accountState: Loadable<Account> = .none,
             subscriberState: Loadable<[Account]> = .none,
             subscribedState: Loadable<[Account]> = .none,
             subscribeState: Loadable<Subscriber> = .none,
             subscriptionInfoState: Loadable<SubscriptionInfo> = .none) {
            self.accountState = accountState
            self.subscriberState = subscriberState
            self.subscribedState = subscribedState
            self.subscribeState = subscribeState
            self.subscriptionInfoState = subscriptionInfoState

            if case let .loaded(account) = accountState,
               account.id != ownAccountId {
                self.ownAccountId = ownAccountId
            } else {
                self.ownAccountId = nil
            }
        }
    }

    enum Action: Equatable {
        case fetchSubscriberInfo

        case fetchAccount
        case accountStateChanged(Loadable<Account>)

        case fetchSubscriber
        case subscriberStateChanged(Loadable<[Account]>)

        case fetchSubscribed
        case subscribedStateChanged(Loadable<[Account]>)

        case fetchSubscriptionInfo
        case sendSubscriptionRequest
        case subscriptionInfoChanged(Loadable<SubscriptionInfo>)
    }

    @Dependency(\.accountService) var service
    @Dependency(\.subscriberService) var subscriberService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    // TODO: Make Subscription API calls
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchSubscriberInfo:
            return .merge(
                [
                    .task { .fetchSubscriber },
                    .task { .fetchSubscribed }
                ]
            )

        case .fetchAccount:
            guard case let .loaded(account) = state.accountState else { return .none }

            return .task { [id = account.id] in
                let account = try await self.service.getAccountBy(id: id)

                return .accountStateChanged(.loaded(account))
            } catch: { error in
                if let apiError = error as? APIError {
                    return .accountStateChanged(.error(apiError))
                } else {
                    return .accountStateChanged(.error(.error(error)))
                }
            }
            .debounce(id: DebounceId(), for: 1, scheduler: self.mainScheduler)
            .receive(on: self.mainScheduler)
            .prepend(.accountStateChanged(.loading))
            .eraseToEffect()

        case let .accountStateChanged(accountState):
            state.accountState = accountState

            if case .loaded = accountState {
                return .task { .fetchSubscriberInfo }
            }

            return .none

        case .fetchSubscriber:

            guard case let .loaded(account) = state.accountState else { return .none }

            return .task { [id = account.id] in
                let subscriberAccounts = try await self.subscriberService.getSubscriberBy(id: id)

                return .subscriberStateChanged(.loaded(subscriberAccounts))
            } catch: { error in
                if let apiError = error as? APIError {
                    return .subscriberStateChanged(.error(apiError))
                } else {
                    return .subscriberStateChanged(.error(.error(error)))
                }
            }
            .receive(on: self.mainScheduler)
            .prepend(.subscriberStateChanged(.loading))
            .eraseToEffect()

        case let .subscriberStateChanged(subscriberState):
            state.subscriberState = subscriberState

            return .none

        case .fetchSubscribed:

            guard case let .loaded(account) = state.accountState else { return .none }

            return .task { [id = account.id] in
                let subscribedAccounts = try await self.subscriberService.getSubscribedBy(id: id)

                return .subscribedStateChanged(.loaded(subscribedAccounts))
            } catch: { error in
                if let apiError = error as? APIError {
                    return .subscribedStateChanged(.error(apiError))
                } else {
                    return .subscribedStateChanged(.error(.error(error)))
                }
            }
            .receive(on: self.mainScheduler)
            .prepend(.subscribedStateChanged(.loading))
            .eraseToEffect()

        case let .subscribedStateChanged(subscribedState):
            state.subscribedState = subscribedState

            return .none

        case .fetchSubscriptionInfo:

            guard let ownAccountId = state.ownAccountId,
                  case let .loaded(account) = state.accountState else { return .none }

            return .task {
                let subscriber = Subscriber(userId: ownAccountId, subscribedUserId: account.id, accepted: false)
                let subscriptionInfo = try await self.subscriberService.subscriptionInfo(subscriber: subscriber)

                return .subscriptionInfoChanged(.loaded(subscriptionInfo))
            } catch: { error in
                if let apiError = error as? APIError {
                    return .subscriptionInfoChanged(.error(apiError))
                } else {
                    return .subscriptionInfoChanged(.error(.error(error)))
                }
            }

        case .sendSubscriptionRequest:

            guard let ownAccountId = state.ownAccountId,
                  case let .loaded(account) = state.accountState else { return .none }

            return .task {
                let subscriber = Subscriber(userId: ownAccountId, subscribedUserId: account.id, accepted: false)
                let subscriptionInfo = try await self.subscriberService.subscribe(subscriber: subscriber)

                return .subscriptionInfoChanged(.loaded(subscriptionInfo))
            } catch: { error in
                if let apiError = error as? APIError {
                    return .subscriptionInfoChanged(.error(apiError))
                } else {
                    return .subscriptionInfoChanged(.error(.error(error)))
                }
            }

        case let .subscriptionInfoChanged(subscriptionInfoState):
            state.subscriptionInfoState = subscriptionInfoState

            return .none
        }
    }
}
