//
//  SearchCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.01.23.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

struct SearchCore: Reducer {

    struct State: Equatable {
        @BindingState
        var searchQuery: String
        var searchAccountState: Loadable<[Account]>

        var accountStates = IdentifiedArrayOf<AccountCore.State>()

        var ownAccount: Account?

        init(searchQuery: String = "",
             searchAccountState: Loadable<[Account]> = .none,
             ownAccount: Account? = nil) {
            self.searchQuery = searchQuery
            self.searchAccountState = searchAccountState
            self.ownAccount = ownAccount
        }
    }

    enum Action: Equatable {
        case searchAccountStateChanged(Loadable<[Account]>)
        case account(id: AccountCore.State.ID, action: AccountCore.Action)
        case view(View)

        public enum View: BindableAction, Equatable {
            case searchBy(String)
            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.searchService) var searchService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case let .view(.searchBy(username)):
                guard let ownAccount = state.ownAccount else { return .none }

                return .run { send in
                    await send(.searchAccountStateChanged(.loading))
                    
                    let accounts = try await self.searchService.searchBy(
                        id: ownAccount.id,
                        username: username
                    )

                    await send(.searchAccountStateChanged(.loaded(accounts)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.searchAccountStateChanged(.error(apiError)))
                    } else {
                        await send(.searchAccountStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: DebounceId(), for: 0.4, scheduler: self.mainScheduler)

            case let .searchAccountStateChanged(searchAccountState):
                state.searchAccountState = searchAccountState

                if case let .loaded(accounts) = searchAccountState {
                    state.accountStates = IdentifiedArray(
                        uniqueElements: accounts.compactMap {
                            AccountCore.State(
                                ownAccountId: state.ownAccount?.id,
                                ownAccount: state.ownAccount,
                                accountState: .loaded($0)
                            )
                        }
                    )
                }

                return .none

            case .account(id: _, action: .view(.blockAccountStateChanged(.loaded))):
                state.searchQuery = ""

                return .send(.view(.searchBy(state.searchQuery)))

            case .account:
                return .none

            case .view(.binding(\.$searchQuery)):
                if state.searchQuery.isEmpty {
                    return .send(.searchAccountStateChanged(.none))
                }

                return .send(.view(.searchBy(state.searchQuery)))

            case .view(.binding):
                return .none

            case .view:
                return .none
            }
        }
        .forEach(\.accountStates, action: /Action.account(id:action:)) {
            AccountCore()
        }
    }
}
