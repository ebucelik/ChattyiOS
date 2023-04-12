//
//  AvailableChatAccountsCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

class AvailableChatAccountsCore: ReducerProtocol {
    struct State: Equatable {
        var accountId: Int?
        var selectedAccount: Account? = nil
        var availableChatAccountsState: Loadable<[Account]>

        init(accountId: Int? = nil,
             availableChatAccountsState: Loadable<[Account]> = .none) {
            self.accountId = accountId
            self.availableChatAccountsState = availableChatAccountsState
        }
    }

    enum Action {
        case onAppear

        case availableChatAccountsStateChanged(Loadable<[Account]>)

        case accountSelected(Account)

        case chatSessionCreated
    }

    @Dependency(\.availableChatAccountsService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceID: Hashable {}

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:

            guard let accountId = state.accountId else {
                return .send(.availableChatAccountsStateChanged(.error(.notFound)))
            }

            return .task {
                let availableChatAccounts = try await self.service.getAvailableChatAccounts(by: accountId)

                return .availableChatAccountsStateChanged(.loaded(availableChatAccounts))
            } catch: { error in
                if let apiError = error as? APIError {
                    return .availableChatAccountsStateChanged(.error(apiError))
                } else {
                    return .availableChatAccountsStateChanged(.error(.error(error)))
                }
            }
            .receive(on: self.mainScheduler)
            .prepend(.availableChatAccountsStateChanged(.loading))
            .eraseToEffect()

        case let .availableChatAccountsStateChanged(availableChatAccountsStateChanged):
            state.availableChatAccountsState = availableChatAccountsStateChanged

            return .none

        case let .accountSelected(selectedAccount):
            state.selectedAccount = selectedAccount

            guard let accountId = state.accountId else { return .none }

            SocketIOClient.shared.createChatSession(
                chatSession: ChatSession(
                    id: 0,
                    fromUserId: accountId,
                    toUserId: selectedAccount.id,
                    username: selectedAccount.username,
                    picture: selectedAccount.picture,
                    available: false
                )
            )

            return .send(.chatSessionCreated)
                .debounce(id: DebounceID(), for: 1, scheduler: self.mainScheduler)

        case .chatSessionCreated:
            return .none
        }
    }
}
