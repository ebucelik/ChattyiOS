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

class RegisterCore: ReducerProtocol {

    enum ViewState {
        case usernameView
        case emailAndPasswordView
        case profilePictureView
    }

    struct State: Equatable {
        var registerState: Loadable<Account>
        var usernameAvailableState: Loadable<Bool>
        var emailAvailableState: Loadable<Bool>
        var passwordValidState: Loadable<Bool>

        var showPassword: Bool = false

        var viewState: ViewState = .usernameView

        var picture: UIImage? = nil

        @BindableState
        var register: Register

        var error: String {
            if case let .error(error) = registerState {
                if case let .unexpectedError(apiError) = error {
                    return apiError
                }

                return error.localizedDescription
            }

            if case let .error(error) = usernameAvailableState {
                if case let .unexpectedError(apiError) = error {
                    return apiError
                }

                return error.localizedDescription
            }

            if case let .error(error) = emailAvailableState {
                if case let .unexpectedError(apiError) = error {
                    return apiError
                }

                return error.localizedDescription
            }

            if case let .error(error) = passwordValidState {
                if case let .unexpectedError(apiError) = error {
                    return apiError
                }

                return error.localizedDescription
            }

            return ""
        }

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
             register: Register = .empty) {
            self.registerState = registerState
            self.usernameAvailableState = usernameAvailableState
            self.emailAvailableState = emailAvailableState
            self.passwordValidState = passwordValidState
            self.register = register
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

        case showUsernameView
        case showEmailAndPasswordView
        case showProfilePictureView

        case setImage(UIImage)

        case usernameAvailableStateChanged(Loadable<Bool>)
        case emailAvailableStateChanged(Loadable<Bool>)
        case passwordValidStateChanged(Loadable<Bool>)

        case showLoginView
        case showFeed(Account)

        case reset

        case binding(BindingAction<State>)
    }

    @Dependency(\.registerService) var service
    @Dependency(\.accountAvailabilityService) var accountAvailabilityService
    @Dependency(\.imageService) var imageService
    @Dependency(\.mainScheduler) var mainScheduler

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .register:
                struct Debounce: Hashable { }

                return .task { [register = state.register, picture = state.picture] in
                    if let picture = picture,
                       let jpegData = picture.jpegData(compressionQuality: 1.0) {
                        let pictureLink = try await self.imageService.uploadImage(imageData: jpegData)

                        let account = try await self.service.register(
                            register: Register(
                                username: register.username,
                                email: register.email,
                                password: register.password,
                                picture: pictureLink
                            )
                        )

                        return .registerStateChanged(.loaded(account))
                    } else {
                        let account = try await self.service.register(register: register)

                        return .registerStateChanged(.loaded(account))
                    }
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .registerStateChanged(.error(apiError))
                    } else {
                        return .registerStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.registerStateChanged(.loading))
                .eraseToEffect()

            case let .registerStateChanged(registerStateDidChanged):
                state.registerState = registerStateDidChanged

                if case let .loaded(account) = registerStateDidChanged {

                    Account.addToUserDefaults(account)

                    return Effect(value: .showFeed(account))
                }

                return .none

            case .checkUsername:
                struct Debounce: Hashable { }

                let username = state.register.username

                return .task {
                    return .usernameAvailableStateChanged(.loaded(try await self.accountAvailabilityService.checkUsername(username: username)))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .usernameAvailableStateChanged(.error(apiError))
                    } else {
                        return .usernameAvailableStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.usernameAvailableStateChanged(.loading))
                .eraseToEffect()

            case let .usernameAvailableStateChanged(usernameAvailabilityStateDidChanged):
                state.usernameAvailableState = usernameAvailabilityStateDidChanged

                if case let .loaded(availability) = usernameAvailabilityStateDidChanged,
                   !availability {
                    state.usernameAvailableState = .error(APIError.unexpectedError("This username is already in use."))
                }

                return .none

            case let .emailAvailableStateChanged(emailAvailableStateDidChanged):
                state.emailAvailableState = emailAvailableStateDidChanged

                if case let .loaded(availability) = emailAvailableStateDidChanged,
                   !availability {
                    state.emailAvailableState = .error(APIError.unexpectedError("This email is already in use."))
                }

                return .none

            case let .passwordValidStateChanged(passwordValidStateDidChanged):
                state.passwordValidState = passwordValidStateDidChanged

                return .none

            case .checkIfEmailIsValid:
                struct Debounce: Hashable { }

                let email = state.register.email

                if email.checkEmailValidation() {
                    return Effect(value: .checkEmail)
                        .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)
                        .prepend(.emailAvailableStateChanged(.loading))
                        .eraseToEffect()
                }

                return Effect(
                    value: .emailAvailableStateChanged(
                        .error(
                            APIError.unexpectedError("Please provide a valid e-mail.")
                        )
                    )
                )
                .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)
                .prepend(.emailAvailableStateChanged(.loading))
                .eraseToEffect()

            case .checkEmail:
                struct Debounce: Hashable { }

                return .task { [email = state.register.email] in
                    return .emailAvailableStateChanged(
                        .loaded(try await self.accountAvailabilityService.checkEmail(email: email))
                    )
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .emailAvailableStateChanged(.error(apiError))
                    } else {
                        return .emailAvailableStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.emailAvailableStateChanged(.loading))
                .eraseToEffect()

            case .checkPassword:
                struct Debounce: Hashable { }

                let password = state.register.password

                let loadable: Loadable = password.count > 4 ? .loaded(true) : .error(APIError.unexpectedError("Please provide a stronger password."))

                return Effect(value: .passwordValidStateChanged(loadable))
                    .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)
                    .prepend(.passwordValidStateChanged(.loading))
                    .eraseToEffect()

            case .showPassword:
                state.showPassword.toggle()

                return .none

            case .showUsernameView:
                state.viewState = .usernameView

                return .none

            case .showEmailAndPasswordView:
                state.viewState = .emailAndPasswordView

                return .none

            case .showProfilePictureView:
                state.viewState = .profilePictureView

                return .none

            case let .setImage(picture):
                state.picture = picture

                return .none

            case .showFeed:
                struct Debounce: Hashable { }

                return Effect(value: .reset)
                    .debounce(id: Debounce(), for: 2, scheduler: self.mainScheduler)

            case .showLoginView:
                return .none

            case .reset:
                state.register = .empty
                state.registerState = .none
                state.usernameAvailableState = .none
                state.emailAvailableState = .none
                state.passwordValidState = .none
                state.picture = nil

                return .none

            case .binding:
                return .none
            }
        }
    }
}
