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
        var entry = EntryCore.State()
    }

    enum Action {
        case onAppear
        case loadAccount
        case accountStateChanged(Loadable<Account?>)

        case feed(FeedCore.Action)
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

                return .none

            case .entry(.showFeed):
                state.showFeed = true

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
            state: \.entry,
            action: /Action.entry
        ) {
            EntryCore()
        }
    }
}
