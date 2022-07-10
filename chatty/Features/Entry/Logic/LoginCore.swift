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

        var showHomepage: Bool

        init(loginState: Loadable<Account> = .none,
             login: Login = .empty,
             showHomepage: Bool = true) {
            self.loginState = loginState
            self.login = login
            self.showHomepage = showHomepage
        }
    }

    enum Action: BindableAction {
        case login
        case loginStateChanged(Loadable<Account>)

        case checkEmail
        case checkPassword

        case binding(BindingAction<State>)
    }

    struct Environment {
        let service: LoginServiceProtocol
        let mainDispatcher: AnySchedulerOf<DispatchQueue>
        let completion: (Bool) -> Void
    }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {

        case .login:
            if state.login.email.isEmpty || state.login.password.isEmpty {
                return Effect(value: .loginStateChanged(.error(APIError.notFound)))
            }

            return environment.service
                .login(login: state.login)
                .receive(on: environment.mainDispatcher)
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

                state.showHomepage = true
                
                environment.completion(true)
            }

            return .none

        case .checkEmail:
            return .none

        case .checkPassword:
            return .none

        case .binding:
            return .none

        }
    }.binding()
}
