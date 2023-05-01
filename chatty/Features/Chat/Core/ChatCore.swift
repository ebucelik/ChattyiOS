//
//  ChatCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 01.05.23.
//

import SwiftHelper
import ComposableArchitecture

class ChatCore: ReducerProtocol {
    struct State: Equatable {
        var chatsState: Loadable<[Chat]>

        @BindingState
        var chat: Chat

        init(chatsState: Loadable<[Chat]> = .loaded([]),
             chat: Chat = .empty) {
            self.chatsState = chatsState
            self.chat = chat
        }
    }

    enum Action: BindableAction {
        case onSend
        case chatsStateChanged(Loadable<[Chat]>)
        case binding(BindingAction<State>)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onSend:
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

            case let .chatsStateChanged(chatsState):
                state.chatsState = chatsState

                return .none

            case .binding:
                return .none
            }
        }
    }
}
