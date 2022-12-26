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

        @BindableState
        var login: Login

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
        case showFeed

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
                    return Effect(value: .loginStateChanged(.error(APIError.notFound)))
                }

                return .task { [login = state.login] in
                    do {
                        return .loginStateChanged(.loaded(try await self.service.login(login: login)))
                    } catch {
                        return .loginStateChanged(.error(error))
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

                    return Effect(value: .showFeed)
                }

                if case let .error(error) = changedState {
                    if let apiError = error as? APIError,
                       case let .unexpectedError(stringError) = apiError {
                        state.error = stringError
                    } else {
                        state.error = "Unexpected error has occured"
                    }
                }

                return .none

            case .showFeed, .showRegisterView:
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
