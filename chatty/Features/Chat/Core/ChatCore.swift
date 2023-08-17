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
        var account: Account
        var receiverAccount: Account? {
            if case let .loaded(receiver) = receiverAccountState {
                return receiver
            }

            return nil
        }
        var receiverAccountState: Loadable<Account> = .none
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
            self.chatsState = chatsState
            self.chatSession = chatSession
            self.chat = chat

            SocketIOClient.shared.receive(
                fromUserId: chatSession.fromUserId,
                toUserId: chatSession.toUserId
            )
        }
    }

    enum Action: BindableAction {
        case onViewAppear
        case onSend
        case onReceive(Chat)
        case chatsStateChanged(Loadable<[Chat]>)
        case onDismissView
        case loadReceiverAccount
        case receiverAccountStateChanged(Loadable<Account>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.chatService) var service
    @Dependency(\.accountService) var accountService

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onViewAppear:
                return .concatenate(
                    [
                        .send(.loadReceiverAccount),
                        .run { [chatSessionId = state.chatSession.id] send in
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
                    ]
                )

            case .onSend:
                state.chat.session = state.chatSession.id
                state.chat.toUserId = state.account.id == state.chatSession.fromUserId
                ? state.chatSession.toUserId
                : state.chatSession.fromUserId
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
                SocketIOClient.shared.cancelListeners(
                    fromUserId: state.chatSession.fromUserId,
                    toUserId: state.chatSession.toUserId
                )
                
                return .none

            case .loadReceiverAccount:
                let receiverAccountId = state.account.id == state.chatSession.toUserId ? state.chatSession.fromUserId
                : state.chatSession.toUserId

                return .run { send in
                    let receiverAccount = try await self.accountService.getAccountBy(id: receiverAccountId)

                    await send(.receiverAccountStateChanged(.loaded(receiverAccount)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.receiverAccountStateChanged(.error(apiError)))
                    } else {
                        await send(.receiverAccountStateChanged(.error(.error(error))))
                    }
                }

            case let .receiverAccountStateChanged(receiverAccountState):
                state.receiverAccountState = receiverAccountState

                return .none

            case .binding(\.$chat.message):
                if state.chat.message.count >= state.messageMaxLength {
                    state.chat.message = String(state.chat.message.prefix(state.messageMaxLength))
                }

                return .none

            case .binding:
                return .none
            }
        }
    }
}
