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
    }

    enum Action {
        case logout
        case logoutStateChanged(Loadable<String>)
    }

    struct Environment {
        let service: LogoutServiceProtocol
        let mainScheduler: AnySchedulerOf<DispatchQueue>
    }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
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
        }
    }
}
