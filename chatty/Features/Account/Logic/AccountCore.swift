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

        init(accountState: Loadable<Account> = .none) {
            self.accountState = accountState
        }
    }

    enum Action: Equatable {
        case fetchAccount
        case accountStateChanged(Loadable<Account>)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchAccount:
            return .none

        case let .accountStateChanged(accountState):
            state.accountState = accountState

            return .none
        }
    }
}
