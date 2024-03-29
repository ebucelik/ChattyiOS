//
//  AvailableChatAccountsView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import SwiftUI
import ComposableArchitecture
import CachedAsyncImage

struct AvailableChatAccountsView: View {

    let store: StoreOf<AvailableChatAccountsCore>

    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    switch viewStore.availableChatAccountsState {
                    case let .loaded(accounts):
                        availableChatAccountsBody(
                            viewStore,
                            accounts: accounts
                        )

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
                .navigationTitle("Available Accounts To Chat")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    @ViewBuilder
    private func availableChatAccountsBody(_ viewStore: ViewStoreOf<AvailableChatAccountsCore>, accounts: [Account]) -> some View {
        if accounts.isEmpty {
            InfoView(
                text: "youandyourpartner"
            )
            .frame(maxWidth: .infinity)
            .listSeparatorSetting()
        } else {
            List {
                ForEach(accounts, id: \.id) { account in
                    HStack(spacing: 20) {
                        CachedAsyncImage(url: URL(string: account.picture), urlCache: .imageCache) { image in
                            image
                                .resizable()
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            AppColor.lightgray
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)

                        Text(account.username)
                            .font(AppFont.body)

                        Spacer()

                        if let selectedAccount = viewStore.selectedAccount,
                           selectedAccount.id == account.id {
                            Image(systemSymbol: .checkmarkCircleFill)
                                .foregroundColor(AppColor.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.accountSelected(account))
                    }
                    .padding()
                }
            }
            .background(Color.white)
            .onAppear {
                UITableView.appearance().backgroundColor = UIColor.clear
            }
        }
    }
}
