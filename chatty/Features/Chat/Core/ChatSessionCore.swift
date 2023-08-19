//
//  ChatSessionCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

class ChatSessionCore: Reducer {
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

    enum Action {
        case chatSessionStateChanged(Loadable<[ChatSession]>)
        case availableChatAccounts(AvailableChatAccountsCore.Action)
        case chat(id: ChatCore.State.ID, action: ChatCore.Action)
        case view(View)

        public enum View: BindableAction, Equatable {
            case onAppear
            case showSubscribedAccountsView
            case cancelListeners(ChatSession)
            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.chatSessionService) var service
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceID: Hashable {}

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                guard let account = state.account else {
                    return .send(.chatSessionStateChanged(.error(.notFound)))
                }

                state.availableChatAccountsState.accountId = account.id

                return .run { send in
                    await send(.chatSessionStateChanged(.loading))

                    let chatSessions = try await self.service.getChatSessions(fromUserId: account.id)

                    await send(.chatSessionStateChanged(.loaded(chatSessions)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.chatSessionStateChanged(.error(apiError)))
                    } else {
                        await send(.chatSessionStateChanged(.error(.error(error))))
                    }
                }

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

            case .view(.showSubscribedAccountsView):
                state.showSubscribedAccountsView.toggle()

                return .none

            case .availableChatAccounts(.onAppear),
                    .availableChatAccounts(.availableChatAccountsStateChanged),
                    .availableChatAccounts(.accountSelected):
                return .none
                
            case .availableChatAccounts(.chatSessionCreated):
                state.showSubscribedAccountsView = false

                return .send(.view(.onAppear))

            case .chat:
                return .none

            case let .view(.cancelListeners(chatSession)):
                SocketIOClient.shared.cancelListeners(
                    fromUserId: chatSession.fromUserId,
                    toUserId: chatSession.toUserId
                )

                return .none

            case .view(.binding):
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
