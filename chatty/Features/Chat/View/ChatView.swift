//
//  ChatView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 01.05.23.
//

import Combine
import SwiftUI
import ComposableArchitecture

struct ChatView: View {
    private let store: StoreOf<ChatCore>
    private let chatPublisher = NotificationCenter
        .default
        .publisher(
            for: .chat
        )

    init(store: StoreOf<ChatCore>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                switch viewStore.chatsState {
                case let .loaded(chats):
                    ForEach(chats, id: \.self) { chat in
                        Text(chat.message)
                    }

                case .none, .error, .loading, .refreshing:
                    EmptyView()
                }

                TextField(
                    "Message",
                    text: viewStore.binding(\.$chat.message)
                )

                Button("Send") {
                    viewStore.send(.onSend)
                }
            }
            .onAppear {
                viewStore.send(.onViewAppear)
            }
            .onReceive(chatPublisher) { publisher in
                if let chat = publisher.object as? Chat {
                    viewStore.send(.onReceive(chat))
                }
            }
            .onDisappear {
                viewStore.send(.onDismissView)
            }
        }
    }
}
