//
//  ChatCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 01.05.23.
//

import SwiftHelper
import ComposableArchitecture
import Foundation

class ChatCore: ReducerProtocol {
    struct State: Equatable {
        var chatsState: Loadable<[Chat]>
        var chatSession: ChatSession

        @BindingState
        var chat: Chat

        init(chatsState: Loadable<[Chat]> = .loaded([]),
             chatSession: ChatSession = .empty,
             chat: Chat = .empty) {
            self.chatsState = chatsState
            self.chatSession = chatSession
            self.chat = chat

            SocketIOClient.shared.receive(chatSession.toUserId)
        }
    }

    enum Action: BindableAction {
        case onViewAppear
        case onSend
        case onReceive(Chat)
        case chatsStateChanged(Loadable<[Chat]>)
        case onDismissView
        case binding(BindingAction<State>)
    }

    @Dependency(\.chatService) var service

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onViewAppear:
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

            case .onSend:
                state.chat.session = state.chatSession.id
                state.chat.toUserId = state.chatSession.toUserId
                state.chat.timestamp = Date.now.timeIntervalSinceReferenceDate

                SocketIOClient.shared.send(
                    chat: state.chat
                )

                guard case var .loaded(chats) = state.chatsState else { return .none }

                chats.append(state.chat)

                return .send(
                    .chatsStateChanged(
                        .loaded(chats)
                    )
                )

            case let .onReceive(chat):
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

            case .onDismissView:
                return .none

            case .binding:
                return .none
            }
        }
    }
}
