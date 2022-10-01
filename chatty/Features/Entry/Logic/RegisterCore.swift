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
import UIKit

class RegisterCore {

    struct State: Equatable {
        var registerState: Loadable<Account>
        var usernameAvailableState: Loadable<Bool>
        var emailAvailableState: Loadable<Bool>
        var passwordValidState: Loadable<Bool>

        var tabSelection: Int = 0
        var showPassword: Bool = false

        @BindableState
        var showImagePicker: Bool = false

        @BindableState
        var profilePhoto: UIImage? = nil

        @BindableState
        var register: Register

        var isLoading: Bool
        var isError: Bool {
            if case .error = registerState {
                return true
            }

            if case .error = usernameAvailableState {
                return true
            }

            if case .error = emailAvailableState {
                return true
            }

            if case .error = passwordValidState {
                return true
            }

            return false
        }
        var error: String
        var isUsernameAvailable: Bool {
            if case let .loaded(availability) = usernameAvailableState {
                return availability
            }

            return false
        }
        private var isEmailAvailable: Bool {
            if case let .loaded(availability) = emailAvailableState {
                return availability
            }

            return false
        }
        private var isPasswordValid: Bool {
            if case let .loaded(availability) = passwordValidState {
                return availability
            }

            return false
        }
        var isEmailAndPasswordValid: Bool {
            return isEmailAvailable && isPasswordValid
        }

        init(registerState: Loadable<Account> = .none,
             usernameAvailableState: Loadable<Bool> = .none,
             emailAvailableState: Loadable<Bool> = .none,
             passwordValidState: Loadable<Bool> = .none,
             register: Register = .empty,
             isLoading: Bool = false,
             error: String = "") {
            self.registerState = registerState
            self.usernameAvailableState = usernameAvailableState
            self.emailAvailableState = emailAvailableState
            self.passwordValidState = passwordValidState
            self.register = register
            self.isLoading = isLoading
            self.error = error
        }
    }

    enum Action: BindableAction {
        case register
        case registerStateChanged(Loadable<Account>)

        case checkUsername
        case checkIfEmailIsValid
        case checkEmail
        case checkPassword

        case showPassword

        case nextTab(Int?)

        case showImagePicker

        case usernameAvailableStateChanged(Loadable<Bool>)
        case emailAvailableStateChanged(Loadable<Bool>)
        case passwordValidStateChanged(Loadable<Bool>)

        case showLoginView
        case showHomepage

        case reset

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
                return Effect(value: .registerStateChanged(.error(APIError.unexpectedError("Formular is not complete."))))
            }

            return .task { [register = state.register] in
                do {
                    return .registerStateChanged(.loaded(try await environment.service.register(register: register)))
                } catch {
                    return .registerStateChanged(.error(error))
                }
            }
            .debounce(id: Debounce(), for: 2, scheduler: environment.mainScheduler)
            .receive(on: environment.mainScheduler)
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
                do {
                    return .usernameAvailableStateChanged(.loaded(try await environment.accountAvailabilityService.checkUsername(username: username)))
                } catch {
                    return .usernameAvailableStateChanged(.error(error))
                }
            }
            .debounce(id: Debounce(), for: 1, scheduler: environment.mainScheduler)
            .receive(on: environment.mainScheduler)
            .prepend(.usernameAvailableStateChanged(.loading))
            .eraseToEffect()

        case let .usernameAvailableStateChanged(usernameAvailabilityStateDidChanged):
            state.usernameAvailableState = usernameAvailabilityStateDidChanged

            if case let .error(error) = usernameAvailabilityStateDidChanged,
               let apiError = error as? APIError,
               case let .unexpectedError(unexpectedError) = apiError {
                state.error = unexpectedError
            } else {
                state.error = ""
            }

            if case let .loaded(availability) = usernameAvailabilityStateDidChanged,
               !availability {
                state.usernameAvailableState = .error(APIError.notFound)
                state.error = "This username is already in use!"
            }

            return .none

        case .checkIfEmailIsValid:
            struct Debounce: Hashable { }

            let email = state.register.email

            if email.checkEmailValidation() {
                return Effect(value: .checkEmail)
                    .debounce(id: Debounce(), for: 1, scheduler: environment.mainScheduler)
                    .prepend(.emailAvailableStateChanged(.loading))
                    .eraseToEffect()
            }

            return Effect(value: .emailAvailableStateChanged(.error(APIError.unexpectedError("Please provide a valid e-mail."))))
                .debounce(id: Debounce(), for: 1, scheduler: environment.mainScheduler)
                .prepend(.emailAvailableStateChanged(.loading))
                .eraseToEffect()

        case .checkEmail:
            struct Debounce: Hashable { }

            return .task { [email = state.register.email] in
                do {
                    return .emailAvailableStateChanged(.loaded(try await environment.accountAvailabilityService.checkEmail(email: email)))
                } catch {
                    return .emailAvailableStateChanged(.error(error))
                }
            }
            .debounce(id: Debounce(), for: 1, scheduler: environment.mainScheduler)
            .receive(on: environment.mainScheduler)
            .prepend(.emailAvailableStateChanged(.loading))
            .eraseToEffect()

        case .checkPassword:
            struct Debounce: Hashable { }

            let password = state.register.password

            let loadable: Loadable = password.count > 4 ? .loaded(true) : .error(APIError.unexpectedError("Please provide a stronger password."))

            return Effect(value: .passwordValidStateChanged(loadable))
                .debounce(id: Debounce(), for: 1, scheduler: environment.mainScheduler)
                .prepend(.passwordValidStateChanged(.loading))
                .eraseToEffect()

        case .showPassword:
            state.showPassword.toggle()

            return .none

        case let .nextTab(tab):
            if let tab = tab {
                state.tabSelection = tab
                state.usernameAvailableState = .none
            }

            return .none

        case .showImagePicker:
            state.showImagePicker.toggle()

            return .none

        case let .emailAvailableStateChanged(emailAvailableStateDidChanged):
            state.emailAvailableState = emailAvailableStateDidChanged

            if case let .error(error) = emailAvailableStateDidChanged,
               let apiError = error as? APIError,
               case let .unexpectedError(unexpectedError) = apiError {
                state.error = unexpectedError
            } else {
                state.error = ""
            }

            return .none

        case let .passwordValidStateChanged(passwordValidStateDidChanged):
            state.passwordValidState = passwordValidStateDidChanged

            if case let .error(error) = passwordValidStateDidChanged,
               let apiError = error as? APIError,
               case let .unexpectedError(unexpectedError) = apiError {
                state.error = unexpectedError
            } else {
                state.error = ""
            }

            return .none

        case .showHomepage:
            struct Debounce: Hashable { }

            return Effect(value: .reset)
                .debounce(id: Debounce(), for: 2, scheduler: environment.mainScheduler)

        case .showLoginView:
            return .none

        case .reset:
            state.tabSelection = 0
            state.register = .empty
            state.registerState = .none
            state.usernameAvailableState = .none
            state.emailAvailableState = .none
            state.passwordValidState = .none
            state.profilePhoto = nil
            state.error = ""

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
