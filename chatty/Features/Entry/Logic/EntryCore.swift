//
//  EntryCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 25.12.22.
//

import Foundation
import ComposableArchitecture

class EntryCore: ReducerProtocol {

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

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .login(.showFeed(account)), let .register(.showFeed(account)):
                state.entryViewState = .login

                return .send(.showFeed(account))

            case .login(.showRegisterView):
                state.entryViewState = .register

                return .none

            case .register(.showLoginView):
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
