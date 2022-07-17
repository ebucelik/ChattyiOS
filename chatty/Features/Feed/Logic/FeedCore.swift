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
        var showHomepage: Bool

        var login: LoginCore.State
        var register: RegisterCore.State

        init(showLoginView: Bool = false,
             showRegisterView: Bool = false,
             showHomepage: Bool = false,
             login: LoginCore.State,
             register: RegisterCore.State) {
            self.showLoginView = showLoginView
            self.showRegisterView = showRegisterView
            self.showHomepage = showHomepage
            self.login = login
            self.register = register
        }
    }

    enum Action {
        case logout
        case logoutStateChanged(Loadable<String>)

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

                return .none

            case .login(.showRegisterView):
                state.showRegisterView = true
                return .none

            case .login(.showHomepage):
                state.showHomepage = true
                return .none

            case .login:
                return .none

            case .register(.showLoginView):
                state.showRegisterView = false
                return .none

            case .register(.showHomepage):
                state.showHomepage = true
                return .none

            case .register:
                return .none
            }
        }
    )
}
