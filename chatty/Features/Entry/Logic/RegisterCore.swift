//
//  RegisterCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import Foundation

import Combine
import ComposableArchitecture
import SwiftHelper

class RegisterCore {

    struct State: Equatable {
        var registerState: Loadable<Account>

        @BindableState
        var register: Register

        var isLoading: Bool
        var isError: Bool
        var error: String

        init(registerState: Loadable<Account> = .none,
             register: Register = .empty,
             isLoading: Bool = false,
             isError: Bool = false,
             error: String = "") {
            self.registerState = registerState
            self.register = register
            self.isLoading = isLoading
            self.isError = isError
            self.error = error
        }
    }

    enum Action: BindableAction {
        case register
        case registerStateChanged(Loadable<Account>)
        case showLoginView
        case showHomepage
        case binding(BindingAction<State>)
    }

    struct Environment {
        let service: RegisterServiceProtocol
        let mainScheduler: AnySchedulerOf<DispatchQueue>
    }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .register:
            struct Debounce: Hashable { }

            if state.register.username.isEmpty ||
                state.register.email.isEmpty ||
                state.register.password.isEmpty {
                return Effect(value: .registerStateChanged(.error(APIError.unexpectedError("Formular not completely filled."))))
            }

            let register = state.register

            return Effect.task {
                try await environment.service
                    .register(register: register)
            }
            .debounce(id: Debounce(), for: 2, scheduler: environment.mainScheduler)
            .receive(on: environment.mainScheduler)
            .compactMap({ .registerStateChanged(.loaded($0)) })
            .catch({ Just(.registerStateChanged(.error($0))) })
            .prepend(.registerStateChanged(.loading))
            .eraseToEffect()

        case let .registerStateChanged(registerStateDidChanged):
            state.registerState = registerStateDidChanged

            if case let .loaded(account) = registerStateDidChanged {

                state.isLoading = false
                state.isError = false

                return Effect(value: .showHomepage)
            }

            if case .none = registerStateDidChanged {
                state.isLoading = false
                state.isError = false
            }

            if .loading == registerStateDidChanged, .refreshing == registerStateDidChanged {
                state.isLoading = true
                state.isError = false
            }

            if case let .error(error) = registerStateDidChanged {
                state.isLoading = false
                state.isError = true

                if let apiError = error as? APIError,
                   case let .unexpectedError(stringError) = apiError {
                    state.error = stringError
                }
            }

            return .none

        case .showHomepage, .showLoginView:
            return .none

        case .binding:
            return .none
        }
    }
}

extension RegisterCore.Environment {
    static var app: RegisterCore.Environment {
        return RegisterCore.Environment(
            service: RegisterService(),
            mainScheduler: .main
        )
    }
}
