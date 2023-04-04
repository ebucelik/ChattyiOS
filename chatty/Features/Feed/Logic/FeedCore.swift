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
    }

    enum Action {
        case logout
        case logoutStateChanged(Loadable<String>)
        case showLoginView
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
                        return .logoutStateChanged(.error(.error(error)))
                    }
                }
                .receive(on: self.mainScheduler)
                .prepend(.logoutStateChanged(.loading))
                .eraseToEffect()

            case let .logoutStateChanged(logoutStateDidChanged):
                state.logoutState = logoutStateDidChanged

                if case let .error(apiError) = logoutStateDidChanged {
                    if case .unauthorized = apiError {
                        return .task {
                            .showLoginView
                        }
                    }
                }

                return .none

            case .showLoginView:
                return .none
            }
        }
    }
}
