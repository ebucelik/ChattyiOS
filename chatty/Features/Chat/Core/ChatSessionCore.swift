//
//  ChatSessionCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

class ChatSessionCore: ReducerProtocol {
    struct State: Equatable {
        var account: Account?
        var chatSessionState: Loadable<[ChatSession]>

        var availableChatAccountsState = AvailableChatAccountsCore.State()

        @BindingState
        var showSubscribedAccountsView: Bool = false

        init(account: Account? = nil,
             chatSessionState: Loadable<[ChatSession]> = .none) {
            self.account = account
            self.chatSessionState = chatSessionState
        }
    }

    enum Action: BindableAction {
        case onAppear

        case chatSessionStateChanged(Loadable<[ChatSession]>)

        case showSubscribedAccountsView

        case availableChatAccounts(AvailableChatAccountsCore.Action)

        case binding(BindingAction<State>)
    }

    @Dependency(\.chatSessionService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceID: Hashable {}

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let account = state.account else {
                    return .send(.chatSessionStateChanged(.error(.notFound)))
                }

                state.availableChatAccountsState.accountId = account.id

                return .task {
                    let chatSessions = try await self.service.getChatSessions(fromUserId: account.id)

                    return .chatSessionStateChanged(.loaded(chatSessions))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .chatSessionStateChanged(.error(apiError))
                    } else {
                        return .chatSessionStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: DebounceID(), for: 1, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.chatSessionStateChanged(.loading))
                .eraseToEffect()

            case let .chatSessionStateChanged(chatSessionState):
                state.chatSessionState = chatSessionState

                return .none

            case .showSubscribedAccountsView:
                state.showSubscribedAccountsView.toggle()

                return .none

            case .availableChatAccounts(.onAppear), .availableChatAccounts(.availableChatAccountsStateChanged), .availableChatAccounts(.accountSelected):
                return .none
                
            case .availableChatAccounts(.chatSessionCreated):
                state.showSubscribedAccountsView = false

                return .send(.onAppear)

            case .binding:
                return .none
            }
        }

        Scope(
            state: \.availableChatAccountsState,
            action: /ChatSessionCore.Action.availableChatAccounts
        ) {
            AvailableChatAccountsCore()
        }
    }
}
