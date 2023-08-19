//
//  SearchView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.01.23.
//

import SwiftHelper
import SwiftUI
import ComposableArchitecture

extension BindingViewStore<SearchCore.State> {
    var view: SearchView.ViewState {
        SearchView.ViewState(
            searchQuery: self.$searchQuery,
            searchAccountState: self.searchAccountState,
            accountStates: self.accountStates,
            ownAccountId: self.ownAccountId
        )
    }
}

struct SearchView: View {

    struct ViewState: Equatable {
        @BindingViewState var searchQuery: String
        var searchAccountState: Loadable<[Account]>
        var accountStates: IdentifiedArrayOf<AccountCore.State>
        var ownAccountId: Int?
    }

    let store: StoreOf<SearchCore>

    var body: some View {
        WithViewStore(store, observe: \.view, send: { .view($0) }) { viewStore in
            NavigationStack {
                switch viewStore.searchAccountState {
                case let .loaded(accounts):
                    List {
                        if accounts.isEmpty {
                            InfoView(text: "No profiles found.")
                        } else {
                            ForEachStore(
                                store.scope(
                                    state: \.accountStates,
                                    action: SearchCore.Action.account(id:action:)
                                )
                            ) { accountStore in
                                NavigationLink {
                                    AccountView(
                                        store: accountStore
                                    )
                                } label: {
                                    WithViewStore(accountStore, observe: \.accountState) { accountState in
                                        if case let .loaded(account) = accountState.state {
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
                        }
                    }
                    .navigationTitle("Search Accounts")
                    .navigationBarTitleDisplayMode(.inline)

                case .loading, .refreshing:
                    LoadingView()

                case .none:
                    VStack {
                        InfoView(text: "Look for friends, family or new people.")
                    }
                    .navigationTitle("Search Accounts")

                case .error:
                    ErrorView()
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .searchable(text: viewStore.$searchQuery, prompt: "Search here 🤩")
        }
    }
}
