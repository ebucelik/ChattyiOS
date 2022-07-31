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
        var accountAvailabilityState: Loadable<Bool>

        @BindableState
        var register: Register

        var isLoading: Bool
        var isError: Bool {
            if case .error = registerState {
                return true
            }

            return false
        }
        var error: String
        var isAccountAvailable: Bool {
            if case let .loaded(availability) = accountAvailabilityState {
                return availability
            }

            return true
        }

        var tabSelection: Int = 0

        init(registerState: Loadable<Account> = .none,
             accountAvailabilityState: Loadable<Bool> = .none,
             register: Register = .empty,
             isLoading: Bool = false,
             error: String = "") {
            self.registerState = registerState
            self.accountAvailabilityState = accountAvailabilityState
            self.register = register
            self.isLoading = isLoading
            self.error = error
        }
    }

    enum Action: BindableAction {
        case register
        case registerStateChanged(Loadable<Account>)

        case checkUsername

        case nextTab(Int?)

        case accountAvailabilityStateChanged(Loadable<Bool>)

        case showLoginView
        case showHomepage

        case binding(BindingAction<State>)
    }

    struct Environment {
        let service: RegisterServiceProtocol
        let accountAvailabilityService: AccountAvailabilityProtocol
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

                return Effect(value: .showHomepage)
            }

            if case .none = registerStateDidChanged {
                state.isLoading = false
            }

            if .loading == registerStateDidChanged, .refreshing == registerStateDidChanged {
                state.isLoading = true
            }

            if case let .error(error) = registerStateDidChanged {
                state.isLoading = false

                if let apiError = error as? APIError,
                   case let .unexpectedError(stringError) = apiError {
                    state.error = stringError
                }
            }

            return .none

        case .checkUsername:
            struct Debounce: Hashable { }

            let username = state.register.username

            return Effect.task {
                try await environment.accountAvailabilityService
                    .checkUsername(username: username)
            }
            .debounce(id: Debounce(), for: 2, scheduler: environment.mainScheduler)
            .receive(on: environment.mainScheduler)
            .compactMap({ .accountAvailabilityStateChanged(.loaded($0)) })
            .catch({ Just(.accountAvailabilityStateChanged(.error($0))) })
            .prepend(.accountAvailabilityStateChanged(.loading))
            .eraseToEffect()

        case let .nextTab(tab):
            if let tab = tab {
                state.tabSelection = tab
            }

            return .none

        case let .accountAvailabilityStateChanged(accountAvailabilityStateDidChanged):
            state.accountAvailabilityState = accountAvailabilityStateDidChanged

            return .none

        case .showHomepage, .showLoginView:
            return .none

        case .binding:
            return .none
        }
    }.binding()
}

extension RegisterCore.Environment {
    static var app: RegisterCore.Environment {
        return RegisterCore.Environment(
            service: RegisterService(),
            accountAvailabilityService: AccountAvailabilityService(),
            mainScheduler: .main
        )
    }
}
