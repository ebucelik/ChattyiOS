//
//  EntryCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 25.12.22.
//

import Foundation
import ComposableArchitecture

class EntryCore: ReducerProtocol {
    struct State: Equatable {
        var showRegister = false
        var login = LoginCore.State()
        var register = RegisterCore.State()
    }

    enum Action {
        case login(LoginCore.Action)
        case register(RegisterCore.Action)
        case showFeed(Account)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .login(.showFeed(account)), let .register(.showFeed(account)):
                return EffectTask(value: .showFeed(account))

            case .login(.showRegisterView):
                state.showRegister = true

                return .none

            case .register(.showLoginView):
                state.showRegister = false

                return .none

            default:
                return .none
            }
        }

        Scope(
            state: \.login,
            action: /Action.login
        ) {
            LoginCore()
        }

        Scope(
            state: \.register,
            action: /Action.register
        ) {
            RegisterCore()
        }
    }
}
