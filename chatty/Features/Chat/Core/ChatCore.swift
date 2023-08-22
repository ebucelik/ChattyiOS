//
//  ChatCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 01.05.23.
//

import SwiftHelper
import ComposableArchitecture
import Foundation

class ChatCore: Reducer {
    struct State: Equatable, Identifiable {
        var id: UUID = UUID()
        var account: Account
        var receiverAccount: Account
        var chatsState: Loadable<[Chat]>
        var chatSession: ChatSession
        var messageMaxLength = 150

        var approachesMaxLength: Bool {
            return chat.message.count >= messageMaxLength - 10
        }

        @BindingState
        var chat: Chat

        init(account: Account,
             chatsState: Loadable<[Chat]> = .loaded([]),
             chatSession: ChatSession = .empty,
             chat: Chat = .empty) {
            self.account = account
            self.receiverAccount = chatSession.receiverAccount
            self.chatsState = chatsState
            self.chatSession = chatSession
            self.chat = chat
        }
    }

    enum Action: Equatable {
        case chatsStateChanged(Loadable<[Chat]>)
        case view(View)

        public enum View: BindableAction, Equatable {
            case onViewAppear
            case onSend
            case onReceive(Chat)
            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.chatService) var service
    @Dependency(\.accountService) var accountService

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .view(.onViewAppear):
                SocketIOClient.shared.receive(
                    fromUserId: state.chatSession.fromUserId,
                    toUserId: state.chatSession.toUserId
                )

                return .run { [chatSessionId = state.chatSession.id] send in
                    await send(.chatsStateChanged(.loading))

                    let chats = try await self.service.getChat(for: chatSessionId)

                    await send(.chatsStateChanged(.loaded(chats)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.chatsStateChanged(.error(apiError)))
                    } else {
                        await send(.chatsStateChanged(.error(.error(error))))
                    }
                }

            case .view(.onSend):
                state.chat.session = state.chatSession.id
                state.chat.toUserId = state.account.id == state.chatSession.fromUserId
                ? state.chatSession.toUserId
                : state.chatSession.fromUserId
                state.chat.timestamp = Date.now.timeIntervalSinceReferenceDate

                SocketIOClient.shared.send(
                    chat: state.chat
                )

                OneSignalClient.shared.sendPush(
                    with: state.chat.message,
                    title: state.receiverAccount.username,
                    accountId: state.receiverAccount.id
                )

                guard case var .loaded(chats) = state.chatsState else { return .none }

                chats.append(state.chat)

                return .send(
                    .chatsStateChanged(
                        .loaded(chats)
                    )
                )

            case let .view(.onReceive(chat)):
                guard case var .loaded(chats) = state.chatsState else { return .none }

                chats.append(chat)

                return .send(
                    .chatsStateChanged(
                        .loaded(chats)
                    )
                )

            case let .chatsStateChanged(chatsState):
                state.chatsState = chatsState

                state.chat = .empty

                return .none

            case .view(.binding(\.$chat)):
                if state.chat.message.count >= state.messageMaxLength {
                    state.chat.message = String(state.chat.message.prefix(state.messageMaxLength))
                }

                return .none

            case .view(.binding):
                return .none

            case .view:
                return .none
            }
        }
    }
}
