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
        var subscribeState: Loadable<Subscriber>
        var subscriptionInfoState: Loadable<Subscriber>

        var isOtherAccount: Bool

        init(accountState: Loadable<Account> = .none,
             subscribeState: Loadable<Subscriber> = .none,
             subscriptionInfoState: Loadable<Subscriber> = .none,
             isOtherAccount: Bool = false) {
            self.accountState = accountState
            self.subscribeState = subscribeState
            self.subscriptionInfoState = subscriptionInfoState
            self.isOtherAccount = isOtherAccount
        }
    }

    enum Action: Equatable {
        case fetchAccount
        case accountStateChanged(Loadable<Account>)
    }

    @Dependency(\.accountService) var service
    @Dependency(\.subscriberService) var subscriberService
    @Dependency(\.mainScheduler) var mainScheduler

    // TODO: Make Subscription API calls
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchAccount:
            struct DebounceId: Hashable {}

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

            return .none
        }
    }
}
