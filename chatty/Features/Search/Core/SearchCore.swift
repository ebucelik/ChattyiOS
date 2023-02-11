//
//  SearchCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.01.23.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

struct SearchCore: ReducerProtocol {

    struct State: Equatable {
        @BindableState
        var searchQuery: String
        var searchAccountState: Loadable<[Account]>

        var ownAccountId: Int?

        init(searchQuery: String = "",
             searchAccountState: Loadable<[Account]> = .none,
             ownAccountId: Int? = nil) {
            self.searchQuery = searchQuery
            self.searchAccountState = searchAccountState
            self.ownAccountId = ownAccountId
        }
    }

    enum Action: BindableAction {
        case searchBy(String)
        case searchAccountStateChanged(Loadable<[Account]>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.searchService) var searchService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .searchBy(username):
                guard let ownAccountId = state.ownAccountId else { return .none }

                return .task {
                    let accounts = try await self.searchService.searchBy(
                        id: ownAccountId,
                        username: username
                    )

                    return .searchAccountStateChanged(.loaded(accounts))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .searchAccountStateChanged(.error(apiError))
                    } else {
                        return .searchAccountStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: DebounceId(), for: 2, scheduler: self.mainScheduler)
                .prepend(.searchAccountStateChanged(.loading))
                .eraseToEffect()

            case let .searchAccountStateChanged(searchAccountState):
                state.searchAccountState = searchAccountState

                return .none

            case .binding(\.$searchQuery):
                if state.searchQuery.isEmpty {
                    return .task {
                        .searchAccountStateChanged(.none)
                    }
                }

                return .task { [username = state.searchQuery] in
                    return .searchBy(username)
                }

            case .binding:
                return .none
            }
        }
    }
}
