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

class LoginCore: Reducer {

    struct State: Equatable {
        var loginState: Loadable<Account>

        @BindingState var login: Login

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

    enum Action: Equatable {
        case loginStateChanged(Loadable<Account>)

        case view(View)

        public enum View: BindableAction, Equatable {
            case login
            case showRegisterView
            case showFeed(Account)
            case showPassword
            case reset
            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.loginService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .view(.login):
                struct Debounce: Hashable { }

                if state.login.email.isEmpty || state.login.password.isEmpty {
                    return .send(.loginStateChanged(.error(APIError.notFound)))
                }

                return .run { [login = state.login] send in
                    await send(.loginStateChanged(.loading))
                    
                    let account = try await self.service.login(login: login)

                    await send(.loginStateChanged(.loaded(account)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.loginStateChanged(.error(apiError)))
                    } else {
                        await send(.loginStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: Debounce(), for: 1, scheduler: self.mainScheduler)

            case let .loginStateChanged(changedState):
                state.loginState = changedState

                if case let .loaded(account) = changedState {

                    Account.addToUserDefaults(account)

                    return .send(.view(.showFeed(account)))
                }

                if case let .error(error) = changedState {
                    if case let .unexpectedError(apiError) = error {
                        state.error = apiError
                    } else {
                        state.error = "Unexpected error has occured"
                    }
                }

                return .none

            case .view(.showFeed), .view(.showRegisterView):
                return .none

            case .view(.showPassword):
                state.showPassword.toggle()

                return .none

            case .view(.reset):
                state.loginState = .none
                state.login = .empty
                state.error = ""

                return .none

            case .view:
                return .none

            }
        }
    }
}
