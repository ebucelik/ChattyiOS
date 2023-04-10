//
//  AvailableChatAccountsView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import SwiftUI
import ComposableArchitecture

struct AvailableChatAccountsView: View {

    let store: StoreOf<AvailableChatAccountsCore>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                switch viewStore.availableChatAccountsState {
                case let .loaded(accounts):
                    if accounts.isEmpty {
                        InfoView(
                            text: "You and your partner have to subscribe each other to be able to chat.")
                        .frame(maxWidth: .infinity)
                        .listSeparatorSetting()
                    } else {
                        List {
                            ForEach(accounts, id: \.id) { account in
                                Text(account.username)
                                    .listSeparatorSetting()
                                    .onTapGesture {
                                        viewStore.send(.accountSelected(account))
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .listStyle(.grouped)
                    }

                case .none, .loading, .refreshing:
                    LoadingView()

                case let .error(error):
                    ErrorView(
                        text: error.localizedDescription,
                        action: { viewStore.send(.onAppear) }
                    )
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
