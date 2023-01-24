//
//  SearchView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.01.23.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {

    let store: StoreOf<SearchCore>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                switch viewStore.searchAccountState {
                case let .loaded(accounts):
                    List {
                        if accounts.isEmpty {
                            Text("No accounts found for this username.")
                        } else {
                            ForEach(accounts, id: \.id) { account in
                                NavigationLink {
                                    AccountView(
                                        store: Store(
                                            initialState: AccountCore.State(
                                                ownAccountId: viewStore.ownAccountId,
                                                accountState: .loaded(account)
                                            ),
                                            reducer: AccountCore()
                                        )
                                    )
                                } label: {
                                    HStack {
                                        ChattyImage(
                                            picture: account.picture,
                                            frame: CGSize(width: 30, height: 30)
                                        )

                                        Text(account.username)
                                            .font(AppFont.body)
                                            .foregroundColor(AppColor.black)

                                        Spacer()
                                    }
                                    .frame(height: 40)
                                }
                            }
                        }
                    }
                    .navigationTitle("Search Accounts")
                    .navigationBarTitleDisplayMode(.inline)

                case .loading, .refreshing:
                    LoadingView()

                case .none:
                    List {
                        EmptyView()
                    }
                    .navigationTitle("Search Accounts")

                case .error:
                    ErrorView()
                }
            }
            .searchable(text: viewStore.binding(\.$searchQuery), prompt: "Search for your friends")
            .textInputAutocapitalization(.never)
        }
    }
}
