//
//  LoginCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation
import Combine

import SwiftHelper
import ComposableArchitecture

class LoginCore: ReducerProtocol {

    struct State: Equatable {
        var loginState: Loadable<Account>

        @BindingState
        var login: Login

        var showPassword = false

        var isError: Bool {
            if case .error = loginState {
                return true
            }

            return false
        }

        var error: String

        init(loginState: Loadable<Account> = .none,
             login: Login = .empty,
             error: String = "") {
            self.loginState = loginState
            self.login = login
            self.error = error
        }
    }

    enum Action: BindableAction {
        case login
        case loginStateChanged(Loadable<Account>)

        case showRegisterView
        case showFeed(Account)
        case showPassword

        case reset

        case binding(BindingAction<State>)
    }

    @Dependency(\.loginService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .login:
                struct Debounce: Hashable { }

                if state.login.email.isEmpty || state.login.password.isEmpty {
                    return .send(.loginStateChanged(.error(APIError.notFound)))
                }

                return .task { [login = state.login] in
                    let account = try await self.service.login(login: login)

                    return .loginStateChanged(.loaded(account))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .loginStateChanged(.error(apiError))
                    } else {
                        return .loginStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: Debounce(), for: .seconds(2), scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.loginStateChanged(.loading))
                .eraseToEffect()

            case let .loginStateChanged(changedState):
                state.loginState = changedState

                if case let .loaded(account) = changedState {

                    Account.addToUserDefaults(account)

                    return .send(.showFeed(account))
                }

                if case let .error(error) = changedState {
                    if case let .unexpectedError(apiError) = error {
                        state.error = apiError
                    } else {
                        state.error = "Unexpected error has occured"
                    }
                }

                return .none

            case .showFeed, .showRegisterView:
                return .none

            case .showPassword:
                state.showPassword.toggle()

                return .none

            case .reset:
                state.loginState = .none
                state.login = .empty
                state.error = ""

                return .none

            case .binding:
                return .none

            }
        }
    }
}
