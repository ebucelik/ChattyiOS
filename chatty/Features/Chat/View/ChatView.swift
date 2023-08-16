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
        .publisher(for: .chat)

    init(store: StoreOf<ChatCore>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ScrollView {
                    ScrollViewReader { reader in
                        VStack {
                            switch viewStore.chatsState {
                            case let .loaded(chats):
                                ForEach(chats, id: \.self) { chat in
                                    HStack {
                                        if chat.toUserId != viewStore.account.id {
                                            Spacer()

                                            HStack {
                                                Text(chat.message)
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 4)
                                            }
                                            .background(AppColor.primary.opacity(0.7))
                                            .cornerRadius(8)

                                            AsyncImage(url: URL(string: viewStore.account.picture)) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                            } placeholder: {
                                                AppColor.lightgray
                                            }
                                            .frame(width: 25, height: 25)
                                            .cornerRadius(12.5)
                                        } else {
                                            if let receiverAccount = viewStore.receiverAccount {
                                                AsyncImage(url: URL(string: receiverAccount.picture)) { image in
                                                    image
                                                        .resizable()
                                                        .frame(width: 25, height: 25)
                                                } placeholder: {
                                                    AppColor.lightgray
                                                }
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(12.5)
                                            }
                                            
                                            HStack {
                                                Text(chat.message)
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 4)
                                            }
                                            .background(AppColor.primary.opacity(0.4))
                                            .cornerRadius(8)

                                            Spacer()
                                        }
                                    }
                                    .padding(4)
                                }
                                .onAppear {
                                    if let last = chats.last {
                                        reader.scrollTo(last)
                                    }
                                }

                            case .none, .error, .loading, .refreshing:
                                EmptyView()
                            }
                        }
                    }
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
            .onDisappear {
                viewStore.send(.onDismissView)
            }
            .onReceive(chatPublisher) { publisher in
                if let chat = publisher.object as? Chat {
                    viewStore.send(.onReceive(chat))
                }
            }
            .navigationTitle(Text(viewStore.account.username))
        }
    }
}
