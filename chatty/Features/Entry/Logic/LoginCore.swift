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
        let mainScheduler: AnySchedulerOf<DispatchQueue>
        let completion: (Bool) -> Void
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
