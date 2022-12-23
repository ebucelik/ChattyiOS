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

class FeedCore: ReducerProtocol {
    struct State: Equatable {
        var logoutState: Loadable<String> = .none

        var showLoginView: Bool
        var showRegisterView: Bool
        var showEntryView: Bool

        var login = LoginCore.State()
        var register = RegisterCore.State()

        init(showLoginView: Bool = false,
             showRegisterView: Bool = false,
             showEntryView: Bool = false) {
            self.showLoginView = showLoginView
            self.showRegisterView = showRegisterView
            self.showEntryView = showEntryView
        }
    }

    enum Action {
        case logout
        case logoutStateChanged(Loadable<String>)
        case showEntryView(Bool?)

        case login(LoginCore.Action)
        case register(RegisterCore.Action)
    }

    @Dependency(\.logoutService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .logout:
                return .task {
                    do {
                        return .logoutStateChanged(.loaded(try await self.service.logout()))
                    } catch {
                        return .logoutStateChanged(.error(error))
                    }
                }
                .receive(on: self.mainScheduler)
                .prepend(.logoutStateChanged(.loading))
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
                    state.showRegisterView = false
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

        Scope(state: \.login, action: /Action.login) {
            LoginCore()
        }

        Scope(state: \.register, action: /Action.register) {
            RegisterCore()
        }
    }
}
