//
//  AccountView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI
import ComposableArchitecture

struct AccountView: View {

    let store: StoreOf<AccountCore>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationStack {
                switch viewStore.accountState {
                case .loading, .refreshing, .none:
                    LoadingView()

                case let .loaded(account):
                    accountBody(with: account, viewStore)

                case let .error(error):
                    ErrorView(
                        error: error.localizedDescription,
                        action: { viewStore.send(.fetchAccount) }
                    )
                }
            }
            .refreshable {
                viewStore.send(.fetchAccount)
            }
            .onAppear {
                if case .none = viewStore.accountState {
                    viewStore.send(.fetchAccount)
                }

                viewStore.send(.fetchSubscriberInfo)
            }
        }
    }

    @ViewBuilder
    private func accountBody(with account: Account, _ viewStore: ViewStoreOf<AccountCore>) -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                ChattyImage(
                    picture: account.picture,
                    frame: CGSize(width: 125, height: 125)
                )

                ChattyDivider()

                HStack(spacing: 16) {
                    NavigationLink {
                        if case let .loaded(subscriberAccounts) = viewStore.subscriberState {
                            SubscriptionView(
                                store: Store(
                                    initialState: SubscriptionCore.State(
                                        accounts: subscriberAccounts,
                                        subscriptionMode: .subscriber
                                    ),
                                    reducer: SubscriptionCore()
                                )
                            )
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Text("Subscriber")
                                .font(AppFont.caption)

                            Text(String(account.subscriberCount))
                                .font(AppFont.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.leading)
                        .foregroundColor(AppColor.black)
                    }

                    ChattyDivider()

                    NavigationLink {
                        if case let .loaded(subscribedAccounts) = viewStore.subscribedState {
                            SubscriptionView(
                                store: Store(
                                    initialState: SubscriptionCore.State(
                                        accounts: subscribedAccounts,
                                        subscriptionMode: .subscribed
                                    ),
                                    reducer: SubscriptionCore()
                                )
                            )
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Text("Subscribed")
                                .font(AppFont.caption)

                            Text(String(account.subscribedCount))
                                .font(AppFont.caption)
                        }
                        .foregroundColor(AppColor.black)
                    }

                    ChattyDivider()

                    VStack(spacing: 10) {
                        Text("Posts")
                            .font(AppFont.caption)

                        Text(String(account.postCount))
                            .font(AppFont.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing)
                }

                ChattyDivider()

                if viewStore.isOtherAccount {
                    ChattyButton(text: "I want to know", action: {})
                        .padding(.horizontal)

                    ChattyDivider()
                }
            }
            .padding()
            .padding(.top, 24)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ChattyIcon(width: 30, height: 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(
            store: Store(
                initialState: AccountCore.State(),
                reducer: AccountCore()
            )
        )
    }
}
#endif
