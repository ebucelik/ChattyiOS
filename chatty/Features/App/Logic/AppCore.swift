//
//  AppCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.12.22.
//

import Foundation
import ComposableArchitecture
import SwiftHelper

class AppCore: Reducer {
    struct State: Equatable {
        var accountState: Loadable<Account?> = .none
        var showFeed = false

        var feed = FeedCore.State()
        var search = SearchCore.State()
        var upload = UploadPostCore.State()
        var chat = ChatSessionCore.State()
        var account = AccountCore.State()
        var entry = EntryCore.State()
    }

    enum Action {
        case onAppear
        case loadAccount
        case accountStateChanged(Loadable<Account?>)
        case setShowFeed(Bool)

        case feed(FeedCore.Action)
        case search(SearchCore.Action)
        case upload(UploadPostCore.Action)
        case chat(ChatSessionCore.Action)
        case account(AccountCore.Action)
        case entry(EntryCore.Action)
    }

    @Dependency(\.accountService) var accountService
    @Dependency(\.mainScheduler) var mainScheduler

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadAccount)

            case .loadAccount:
                guard let account = Account.getFromUserDefaults()
                else { return .send(.accountStateChanged(.loaded(nil))) }

                state.feed.account = account
                state.search.ownAccountId = account.id
                state.upload.ownAccountId = account.id
                state.chat.account = account

                return .run { send in
                    let loadedAccount = try await self.accountService.getAccountBy(id: account.id)

                    if loadedAccount.username != account.username ||
                        loadedAccount.email != account.email ||
                        loadedAccount.picture != account.picture ||
                        loadedAccount.subscriberCount != account.subscriberCount ||
                        loadedAccount.subscribedCount != account.subscribedCount ||
                        loadedAccount.postCount != account.postCount {

                        Account.addToUserDefaults(loadedAccount)

                        await send(.accountStateChanged(.loaded(loadedAccount)))
                    } else {
                        await send(.accountStateChanged(.loaded(account)))
                    }
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.accountStateChanged(.error(apiError)))
                    } else {
                        await send(.accountStateChanged(.error(.error(error))))
                    }
                }

            case let .accountStateChanged(accountStateChanged):
                state.accountState = accountStateChanged

                if case let .loaded(loadedAccount) = accountStateChanged,
                   let account = loadedAccount {
                    state.account = AccountCore.State(accountState: .loaded(account))
                }

                return .none

            case let .setShowFeed(showFeed):
                state.showFeed = showFeed

                return .none

                // MARK: EntryCore
            case let .entry(.showFeed(account)):
                state.accountState = .loaded(account)
                state.feed.account = account
                state.search.ownAccountId = account.id
                state.chat.account = account
                state.upload.ownAccountId = account.id

                if case let .loaded(loadedAccount) = state.accountState,
                   let account = loadedAccount {
                    state.account = AccountCore.State(accountState: Loadable<Account>.loaded(account))
                }

                return .send(.setShowFeed(true))

                // MARK: AccountCore:
            case .account(.view(.loggedOut)):
                state.feed = FeedCore.State()
                state.search = SearchCore.State()
                state.upload = UploadPostCore.State()
                state.chat = ChatSessionCore.State()
                state.account = AccountCore.State()

                return .send(.onAppear)

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
            state: \.search,
            action: /Action.search
        ) {
            SearchCore()
        }

        Scope(
            state: \.upload,
            action: /Action.upload
        ) {
            UploadPostCore()
        }

        Scope(
            state: \.chat,
            action: /Action.chat
        ) {
            ChatSessionCore()
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
