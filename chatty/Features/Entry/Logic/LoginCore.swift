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

class LoginCore {

    struct State: Equatable {
        var loginState: Loadable<Account>

        @BindableState
        var login: Login

        var showRegister: Bool
        var isLoading: Bool
        var isError: Bool

        var error: String

        init(loginState: Loadable<Account> = .none,
             login: Login = .empty,
             showRegister: Bool = false,
             isLoading: Bool = false,
             isError: Bool = false,
             error: String = "") {
            self.loginState = loginState
            self.login = login
            self.showRegister = showRegister
            self.isLoading = isLoading
            self.isError = isError
            self.error = error
        }
    }

    enum Action: BindableAction {
        case login
        case loginStateChanged(Loadable<Account>)

        case showRegisterView
        case showHomepage

        case binding(BindingAction<State>)
    }

    struct Environment {
        let service: LoginServiceProtocol
        let mainScheduler: AnySchedulerOf<DispatchQueue>
    }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {

        case .login:
            struct Debounce: Hashable { }

            if state.login.email.isEmpty || state.login.password.isEmpty {
                return Effect(value: .loginStateChanged(.error(APIError.notFound)))
            }

            let login = state.login

            return Effect.task {
                try await environment.service
                    .login(login: login)
            }
            .debounce(id: Debounce(), for: .seconds(2), scheduler: environment.mainScheduler)
            .receive(on: environment.mainScheduler)
            .compactMap({ .loginStateChanged(.loaded($0)) })
            .catch({ Just(.loginStateChanged(.error($0))) })
            .prepend(.loginStateChanged(.loading))
            .eraseToEffect()

        case let .loginStateChanged(changedState):
            state.loginState = changedState

            if case let .loaded(account) = changedState {

                do {
                    let data = try JSONEncoder().encode(account)
                    UserDefaults.standard.set(data, forKey: "account")
                } catch {
                    print("ERROR: \(error)")
                }

                state.isLoading = false
                state.isError = false

                return Effect(value: .showHomepage)
            }

            if case .none = changedState {
                state.isLoading = false
                state.isError = false
            }

            if .loading == changedState || .refreshing == changedState {
                state.isLoading = true
                state.isError = false
            }
            
            if case let .error(error) = changedState {
                state.isLoading = false
                state.isError = true

                if let apiError = error as? APIError,
                   case let .unexpectedError(stringError) = apiError {
                    state.error = stringError
                }
            }

            return .none

        case .showHomepage, .showRegisterView:
            return .none

        case .binding:
            return .none

        }
    }.binding()
}

extension LoginCore.Environment {
    static var app: LoginCore.Environment {
        return LoginCore.Environment(
            service: LoginService(),
            mainScheduler: .main
        )
    }
}
