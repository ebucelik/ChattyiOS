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

        var chatStates = IdentifiedArrayOf<ChatCore.State>()

        var isChatSessionNotAvailable: Bool {
            guard let account = account,
                  case let .loaded(chatSessions) = chatSessionState
            else { return true }

            if chatSessions.first(where: { $0.fromUserId == account.id }) != nil {
                return false
            }

            if chatSessions.first(where: { $0.available }) != nil {
                return false
            }

            return true
        }

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

        case chat(id: ChatCore.State.ID, action: ChatCore.Action)

        case cancelListeners(ChatSession)

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
                .prepend(.chatSessionStateChanged(.loading))
                .eraseToEffect()

            case let .chatSessionStateChanged(chatSessionState):
                state.chatSessionState = chatSessionState

                if case let .loaded(chatSessions) = chatSessionState,
                   let account = state.account {
                    state.chatStates = IdentifiedArray(
                        uniqueElements: chatSessions.compactMap {
                            ChatCore.State(
                                account: account,
                                chatSession: $0
                            )
                        }
                    )
                }

                return .none

            case .showSubscribedAccountsView:
                state.showSubscribedAccountsView.toggle()

                return .none

            case .availableChatAccounts(.onAppear),
                    .availableChatAccounts(.availableChatAccountsStateChanged),
                    .availableChatAccounts(.accountSelected):
                return .none
                
            case .availableChatAccounts(.chatSessionCreated):
                state.showSubscribedAccountsView = false

                return .send(.onAppear)

            case .chat:
                return .none

            case let .cancelListeners(chatSession):
                SocketIOClient.shared.cancelListeners(
                    fromUserId: chatSession.fromUserId,
                    toUserId: chatSession.toUserId
                )

                return .none

            case .binding:
                return .none
            }
        }
        .forEach(\.chatStates, action: /Action.chat) {
            ChatCore()
        }

        Scope(
            state: \.availableChatAccountsState,
            action: /ChatSessionCore.Action.availableChatAccounts
        ) {
            AvailableChatAccountsCore()
        }
    }
}
