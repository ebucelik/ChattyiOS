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

class RegisterCore: Reducer {

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

        @BindingState
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

    enum Action: Equatable {
        case registerStateChanged(Loadable<Account>)

        case usernameAvailableStateChanged(Loadable<Bool>)
        case emailAvailableStateChanged(Loadable<Bool>)
        case passwordValidStateChanged(Loadable<Bool>)

        case view(View)

        public enum View: BindableAction, Equatable {
            case register

            case checkUsername
            case checkIfEmailIsValid
            case checkEmail
            case checkPassword

            case showPassword

            case showUsernameView
            case showEmailAndPasswordView
            case showProfilePictureView

            case setImage(UIImage)

            case showLoginView
            case showFeed(Account)

            case reset

            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.registerService) var service
    @Dependency(\.accountAvailabilityService) var accountAvailabilityService
    @Dependency(\.imageService) var imageService
    @Dependency(\.mainScheduler) var mainScheduler

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .view(.register):
                struct Debounce: Hashable { }

                return .run { [register = state.register, picture = state.picture] send in
                    await send(.registerStateChanged(.loading))

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

                        await send(.registerStateChanged(.loaded(account)))
                    } else {
                        let account = try await self.service.register(register: register)

                        await send(.registerStateChanged(.loaded(account)))
                    }
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.registerStateChanged(.error(apiError)))
                    } else {
                        await send(.registerStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)

            case let .registerStateChanged(registerStateDidChanged):
                state.registerState = registerStateDidChanged

                if case let .loaded(account) = registerStateDidChanged {

                    Account.addToUserDefaults(account)

                    return .send(.view(.showFeed(account)))
                }

                return .none

            case .view(.checkUsername):
                struct Debounce: Hashable { }

                let username = state.register.username

                return .run { send in
                    await send(.usernameAvailableStateChanged(.loading))

                    let checkUsername = try await self.accountAvailabilityService.checkUsername(username: username)

                    await send(.usernameAvailableStateChanged(.loaded(checkUsername)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.usernameAvailableStateChanged(.error(apiError)))
                    } else {
                        await send(.usernameAvailableStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: Debounce(), for: 0.4, scheduler: self.mainScheduler)

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

            case .view(.checkIfEmailIsValid):
                struct Debounce: Hashable { }

                let email = state.register.email

                if email.checkEmailValidation() {
                    return .concatenate(
                        .send(.emailAvailableStateChanged(.loading)),
                        .send(.view(.checkEmail))
                    )
                    .debounce(id: Debounce(), for: 0.4, scheduler: self.mainScheduler)
                }

                return .concatenate(
                    .send(.emailAvailableStateChanged(.loading)),
                    .send(
                        .emailAvailableStateChanged(
                            .error(
                                APIError.unexpectedError("Please provide a valid e-mail.")
                            )
                        )
                    )
                )
                .debounce(id: Debounce(), for: 0.4, scheduler: self.mainScheduler)

            case .view(.checkEmail):
                struct Debounce: Hashable { }

                return .run { [email = state.register.email] send in
                    await send(.emailAvailableStateChanged(.loading))

                    await send(
                        .emailAvailableStateChanged(
                            .loaded(try await self.accountAvailabilityService.checkEmail(email: email))
                        )
                    )
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.emailAvailableStateChanged(.error(apiError)))
                    } else {
                        await send(.emailAvailableStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: Debounce(), for: 0.4, scheduler: self.mainScheduler)

            case .view(.checkPassword):
                struct Debounce: Hashable { }

                let password = state.register.password

                let loadable: Loadable = password.count > 4 ? .loaded(true) : .error(APIError.unexpectedError("Please provide a stronger password."))

                return .concatenate(
                    .send(.passwordValidStateChanged(.loading)),
                    .send(.passwordValidStateChanged(loadable))
                )
                .debounce(id: Debounce(), for: 0.4, scheduler: self.mainScheduler)

            case .view(.showPassword):
                state.showPassword.toggle()

                return .none

            case .view(.showUsernameView):
                state.viewState = .usernameView

                return .none

            case .view(.showEmailAndPasswordView):
                state.viewState = .emailAndPasswordView

                return .none

            case .view(.showProfilePictureView):
                state.viewState = .profilePictureView

                return .none

            case let .view(.setImage(picture)):
                state.picture = picture

                return .none

            case .view(.showFeed):
                struct Debounce: Hashable { }

                return .send(.view(.reset))
                .debounce(id: Debounce(), for: 2, scheduler: self.mainScheduler)

            case .view(.showLoginView):
                return .none

            case .view(.reset):
                state.register = .empty
                state.registerState = .none
                state.usernameAvailableState = .none
                state.emailAvailableState = .none
                state.passwordValidState = .none
                state.viewState = .usernameView
                state.picture = nil

                return .none

            case .view(.binding):
                return .none

            case .view:
                return .none
            }
        }
    }
}
