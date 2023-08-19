//
//  EntryCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 25.12.22.
//

import Foundation
import ComposableArchitecture

class EntryCore: Reducer {

    enum EntryViewState {
        case login
        case register
    }

    struct State: Equatable {
        var entryViewState: EntryViewState = .login
        var login = LoginCore.State()
        var register = RegisterCore.State()
    }

    enum Action {
        case login(LoginCore.Action)
        case register(RegisterCore.Action)
        case showFeed(Account)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .login(.view(.showFeed(account))), let .register(.view(.showFeed(account))):
                state.entryViewState = .login

                return .send(.showFeed(account))

            case .login(.view(.showRegisterView)):
                state.entryViewState = .register

                return .none

            case .register(.view(.showLoginView)):
                state.entryViewState = .login

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
