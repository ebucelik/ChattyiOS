//
//  FeedCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.07.22.
//

import Foundation

import SwiftHelper
import ComposableArchitecture
import Combine

class FeedCore {

    struct State: Equatable {
        var logoutState: Loadable<String> = .none

        var showLoginView: Bool
        var showRegisterView: Bool
        var showEntryView: Bool

        var login: LoginCore.State
        var register: RegisterCore.State

        init(showLoginView: Bool = false,
             showRegisterView: Bool = false,
             showEntryView: Bool = false,
             login: LoginCore.State,
             register: RegisterCore.State) {
            self.showLoginView = showLoginView
            self.showRegisterView = showRegisterView
            self.showEntryView = showEntryView
            self.login = login
            self.register = register
        }
    }

    enum Action {
        case logout
        case logoutStateChanged(Loadable<String>)
        case showEntryView(Bool?)

        case login(LoginCore.Action)
        case register(RegisterCore.Action)
    }

    struct Environment {
        let service: LogoutServiceProtocol
        let mainScheduler: AnySchedulerOf<DispatchQueue>
    }

    static let reducer: Reducer<State, Action, Environment> = .combine(
        LoginCore.reducer.pullback(
            state: \.login,
            action: /Action.login,
            environment: { _ in .app }
        ),

        RegisterCore.reducer.pullback(
            state: \.register,
            action: /Action.register,
            environment: { _ in .app }
        ),

        Reducer { state, action, environment in
            switch action {
            case .logout:
                return Effect.task {
                    try await environment.service
                        .logout()
                }
                .receive(on: environment.mainScheduler)
                .compactMap({
                    .logoutStateChanged(.loaded($0))
                })
                .catch({
                    Just(.logoutStateChanged(.error($0)))
                })
                .eraseToEffect()

            case let .logoutStateChanged(logoutStateDidChanged):
                state.logoutState = logoutStateDidChanged

                if case let .error(error) = logoutStateDidChanged {
                    if let apiError = error as? APIError,
                       case .unauthorized = apiError {
                        return Effect(value: .showEntryView(true))
                    }
                }

                return .none

            case let .showEntryView(value):
                if let showOrHide = value {
                    state.showEntryView = showOrHide
                }

                return .none

                // MARK: - LoginCore Actions
            case .login(.showRegisterView):
                state.showRegisterView = true
                return .none

            case .login(.showHomepage):
                return Effect(value: .showEntryView(false))

            case .login:
                return .none

                // MARK: - RegisterCore Actions
            case .register(.showLoginView):
                state.showRegisterView = false
                return .none

            case .register(.showHomepage):
                return Effect(value: .showEntryView(false))

            case .register:
                return .none
            }
        }
    )
}
