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
            ZStack {
                VStack {
                    ScrollView {
                        ScrollViewReader { reader in
                            VStack {
                                switch viewStore.chatsState {
                                case let .loaded(chats):
                                    chatBody(
                                        chats,
                                        viewStore,
                                        reader
                                    )

                                case .none, .error, .loading, .refreshing:
                                    EmptyView()
                                }
                            }
                        }
                    }

                    messageBody(viewStore)
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
            .onTapGesture {
                UniversalHelper.resignFirstResponder()
            }
        }
    }

    @ViewBuilder
    private func chatBody(
        _ chats: [Chat],
        _ viewStore: ViewStoreOf<ChatCore>,
        _ reader: ScrollViewProxy
    ) -> some View {
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
        .onChange(of: chats) { chatsValue in
            if let last = chatsValue.last {
                reader.scrollTo(last)
            }
        }
    }

    @ViewBuilder
    private func messageBody(_ viewStore: ViewStoreOf<ChatCore>) -> some View {
        HStack {
            HStack {
                TextField(
                    "Send a message ...",
                    text: viewStore.binding(\.$chat.message),
                    axis: .vertical
                )
                .multilineTextAlignment(.leading)
                .lineLimit(5)
                .padding()
            }
            .background(.white)
            .cornerRadius(8)

            Text("\(viewStore.chat.message.count)/\(viewStore.messageMaxLength)")
                .foregroundColor(viewStore.approachesMaxLength ? AppColor.error : AppColor.primary)
                .font(viewStore.approachesMaxLength ? .caption.bold() : .caption)
                .frame(width: 50)

            Button {
                viewStore.send(.onSend)
            } label: {
                Image(systemSymbol: .paperplaneCircleFill)
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
            }
            .tint(AppColor.primary)
            .disabled(viewStore.chat.message.isEmpty)
            .opacity(viewStore.chat.message.isEmpty ? 0.8 : 1.0)
        }
        .padding()
        .background(AppColor.primary.opacity(0.2))
    }
}
