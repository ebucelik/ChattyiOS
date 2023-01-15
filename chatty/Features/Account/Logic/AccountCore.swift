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
        var isOtherAccount: Bool

        init(accountState: Loadable<Account> = .none, isOtherAccount: Bool = false) {
            self.accountState = accountState
            self.isOtherAccount = isOtherAccount
        }
    }

    enum Action: Equatable {
        case fetchAccount
        case accountStateChanged(Loadable<Account>)
    }

    @Dependency(\.accountService) var service
    @Dependency(\.mainScheduler) var mainScheduler

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
