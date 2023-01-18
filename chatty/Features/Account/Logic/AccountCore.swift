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
        var accountState: Loadable<Account>
        var subscriberState: Loadable<[Account]>
        var subscribedState: Loadable<[Account]>
        var subscribeState: Loadable<Subscriber>
        var subscriptionInfoState: Loadable<Subscriber>

        var isOtherAccount: Bool

        @BindableState
        var showSubscribedView: Bool = false

        @BindableState
        var showSubscriberView: Bool = false

        init(accountState: Loadable<Account> = .none,
             subscriberState: Loadable<[Account]> = .none,
             subscribedState: Loadable<[Account]> = .none,
             subscribeState: Loadable<Subscriber> = .none,
             subscriptionInfoState: Loadable<Subscriber> = .none,
             isOtherAccount: Bool = false) {
            self.accountState = accountState
            self.subscriberState = subscriberState
            self.subscribedState = subscribedState
            self.subscribeState = subscribeState
            self.subscriptionInfoState = subscriptionInfoState
            self.isOtherAccount = isOtherAccount
        }
    }

    enum Action: Equatable, BindableAction {
        case fetchSubscriberInfo

        case fetchAccount
        case accountStateChanged(Loadable<Account>)

        case fetchSubscriber
        case subscriberStateChanged(Loadable<[Account]>)

        case fetchSubscribed
        case subscribedStateChanged(Loadable<[Account]>)

        case showSubscribedView
        case showSubscriberView

        case binding(BindingAction<State>)
    }

    @Dependency(\.accountService) var service
    @Dependency(\.subscriberService) var subscriberService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    // TODO: Make Subscription API calls
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

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

            case .showSubscribedView:
                state.showSubscribedView.toggle()

                return .none

            case .showSubscriberView:
                state.showSubscriberView.toggle()

                return .none

            case .binding:
                return .none
            }
        }
    }
}
