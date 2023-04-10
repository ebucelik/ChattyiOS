//
//  ChatSessionView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import SwiftUI
import ComposableArchitecture

struct ChatSessionView: View {

    let store: StoreOf<ChatSessionCore>

    init(store: StoreOf<ChatSessionCore>) {
        self.store = store
    }

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                VStack {
                    switch viewStore.chatSessionState {
                    case let .loaded(chatSessions):
                        chatSessionBody(viewStore, chatSessions: chatSessions)

                    case .none, .loading, .refreshing:
                        LoadingView()

                    case let .error(error):
                        ErrorView(
                            text: error.localizedDescription,
                            action: { viewStore.send(.onAppear) }
                        )
                    }
                }
                .onChange(of: viewStore.account) { _ in
                    viewStore.send(.onAppear)
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemSymbol: .plus)
                            .onTapGesture {
                                viewStore.send(.showSubscribedAccountsView)
                            }
                    }
                }
                .sheet(isPresented: viewStore.binding(\.$showSubscribedAccountsView)) {
                    AvailableChatAccountsView(
                        store: store.scope(
                            state: \.availableChatAccountsState,
                            action: ChatSessionCore.Action.availableChatAccounts
                        )
                    )
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func chatSessionBody(_ viewStore: ViewStoreOf<ChatSessionCore>, chatSessions: [ChatSession]) -> some View {
        if chatSessions.isEmpty {
            InfoView(
                text: """
                            There are currently no chats available.
                            Start a chat now 🥸
                            """)
            .frame(maxWidth: .infinity)
            .listSeparatorSetting()
        } else {
            List {
                ForEach(chatSessions, id: \.id) { chatSession in
                    HStack(spacing: 20) {
                        AsyncImage(url: URL(string: chatSession.picture)) { image in
                            image
                                .resizable()
                                .frame(width: 80, height: 80)
                        } placeholder: {
                            AppColor.lightgray
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(40)

                        Text(chatSession.username)
                            .font(AppFont.headline)
                    }
                        .listSeparatorSetting()
                        .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .listStyle(.grouped)
            .refreshable {
                viewStore.send(.onAppear)
            }
        }
    }
}
