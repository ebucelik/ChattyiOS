//
//  AppCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.12.22.
//

import Foundation
import ComposableArchitecture
import SwiftHelper

class AppCore: ReducerProtocol {
    struct State: Equatable {
        var accountState: Loadable<Account?> = .none
        var showFeed = false

        var feed = FeedCore.State()
        var account = AccountCore.State()
        var entry = EntryCore.State()
    }

    enum Action {
        case onAppear
        case loadAccount
        case accountStateChanged(Loadable<Account?>)

        case feed(FeedCore.Action)
        case account(AccountCore.Action)
        case entry(EntryCore.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return EffectTask(value: .loadAccount)

            case .loadAccount:
                return EffectTask(
                    value: .accountStateChanged(
                        .loaded(Account.getFromUserDefaults())
                    )
                )

            case let .accountStateChanged(accountStateChanged):
                state.accountState = accountStateChanged

                if case let .loaded(loadedAccount) = accountStateChanged,
                   let account = loadedAccount {
                    state.account = AccountCore.State(accountState: .loaded(account))
                }

                return .none

            case let .entry(.showFeed(account)):
                state.accountState = .loaded(account)
                state.showFeed = true

                if case let .loaded(loadedAccount) = state.accountState,
                   let account = loadedAccount {
                    state.account = AccountCore.State(accountState: Loadable<Account>.loaded(account))
                }

                return .none

            default:
                return .none
            }
        }

        Scope(
            state: \.feed,
            action: /Action.feed
        ) {
            FeedCore()
        }

        Scope(
            state: \.account,
            action: /Action.account
        ) {
            AccountCore()
        }

        Scope(
            state: \.entry,
            action: /Action.entry
        ) {
            EntryCore()
        }
    }
}
