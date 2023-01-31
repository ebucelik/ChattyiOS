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

        var subscriptionRequestCoreState: SubscriptionRequestCore.State?

        var isOtherAccount: Bool {
            ownAccountId != nil
        }

        var newUpdatesAvailable: Bool = false

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

            guard case let .loaded(account) = accountState else {
                self.ownAccountId = nil
                return
            }

            self.subscriptionRequestCoreState = SubscriptionRequestCore.State(ownAccountId: account.id)

            if let ownAccountId = ownAccountId,
               account.id != ownAccountId {
                self.ownAccountId = ownAccountId
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

        case subscriptionRequest(SubscriptionRequestCore.Action)

        case newUpdatesAvailable
    }

    @Dependency(\.accountService) var service
    @Dependency(\.subscriberService) var subscriberService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
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
                    return .merge(
                        [
                            .task { .fetchSubscriberInfo },
                            .task { .fetchSubscriptionInfo }
                        ]
                    )
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

            case .newUpdatesAvailable:
                state.newUpdatesAvailable.toggle()

                return .none

                // MARK: SubscriptionRequestCore
            case .subscriptionRequest(.subscriptionAccepted):
                return .task { .newUpdatesAvailable }

            case .subscriptionRequest:
                return .none
            }
        }
        .ifLet(\.subscriptionRequestCoreState, action: /Action.subscriptionRequest) {
            SubscriptionRequestCore()
        }
    }
}
