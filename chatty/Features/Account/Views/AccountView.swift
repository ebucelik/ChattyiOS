//
//  AccountView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI
import ComposableArchitecture
import SwiftHelper

struct AccountView: View {

    let store: StoreOf<AccountCore>

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                switch viewStore.accountState {
                case .loading, .refreshing, .none:
                    LoadingView()

                case let .loaded(account):
                    accountBody(with: account, viewStore)
                        .refreshable {
                            viewStore.send(.fetchAccount)
                        }
                        .onAppear {
                            if viewStore.newUpdatesAvailable {
                                viewStore.send(.newUpdatesAvailable)
                                viewStore.send(.fetchAccount)
                            }
                        }

                case let .error(error):
                    ErrorView(
                        text: error.localizedDescription,
                        action: { viewStore.send(.fetchAccount) }
                    )
                }
            }
            .onAppear {
                viewStore.send(.fetchAccount)
            }
            .handleNavigationView(isOtherAccount: viewStore.isOtherAccount)
            .sheet(isPresented: viewStore.binding(\.$showMore)) {
                MoreView(
                    onLogoutTap: { viewStore.send(.logout) }
                )
            }
        }
    }

    @ViewBuilder
    private func accountBody(with account: Account, _ viewStore: ViewStoreOf<AccountCore>) -> some View {
        GeometryReader { reader in
            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    ChattyImage(
                        picture: account.picture,
                        frame: CGSize(width: 125, height: 125)
                    )

                    Text("@\(account.username)")
                        .font(AppFont.title3.bold())

                    ChattyDivider()

                    HStack(spacing: 16) {
                        NavigationLink {
                            if case let .loaded(subscriberAccounts) = viewStore.subscriberState {
                                SubscriptionView(
                                    store: Store(
                                        initialState: SubscriptionCore.State(
                                            ownAccountId: account.id,
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
                        .disabled(viewStore.isOtherAccount)

                        ChattyDivider()

                        NavigationLink {
                            if case let .loaded(subscribedAccounts) = viewStore.subscribedState {
                                SubscriptionView(
                                    store: Store(
                                        initialState: SubscriptionCore.State(
                                            ownAccountId: account.id,
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
                            .frame(maxWidth: .infinity)
                            .foregroundColor(AppColor.black)
                        }
                        .disabled(viewStore.isOtherAccount)

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

                    subscriptionBody(viewStore)

                    postBody(viewStore, reader: reader)
                }
                .padding()
                .padding(.top, 24)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            IfLetStore(
                                store.scope(
                                    state: \.subscriptionRequestCoreState,
                                    action: AccountCore.Action.subscriptionRequest
                                ),
                                then: { store in
                                    SubscriptionRequestView(
                                        store: store
                                    )
                                }
                            )
                        } label: {
                            Image(systemName: "person.fill.badge.plus")
                                .foregroundColor(AppColor.primary)
                                .opacity(viewStore.isOtherAccount ? 0 : 1)
                        }
                        .disabled(viewStore.isOtherAccount)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(AppColor.gray)
                            .opacity(viewStore.isOtherAccount ? 0 : 1)
                            .onTapGesture {
                                viewStore.send(.showMore)
                            }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    @ViewBuilder
    private func subscriptionBody(_ viewStore: ViewStoreOf<AccountCore>) -> some View {
        if viewStore.isOtherAccount {
            switch viewStore.subscriptionInfoState {
            case let .loaded(subscriptionInfo):
                ChattyButton(
                    text: subscriptionInfo.status,
                    backgroundColor: subscriptionInfo.accepted ? nil : AppColor.gray,
                    action: { viewStore.send(.declineOrCancelSubscriptionRequest) }
                )
                .padding(.horizontal)

            case .loading, .refreshing, .none:
                ChattyButton(
                    isLoading: true,
                    action: {}
                )
                .padding(.horizontal)
                .onAppear {
                    viewStore.send(.fetchSubscriptionInfo)
                }

            case let .error(apiError):
                if case let .unexpectedError(message) = apiError {
                    ChattyButton(
                        text: message,
                        action: { viewStore.send(.sendSubscriptionRequest) }
                    )
                    .padding(.horizontal)
                } else {
                    ChattyButton(
                        text: "Error",
                        action: {}
                    )
                    .padding(.horizontal)
                    .disabled(true)
                    .opacity(0.5)
                }
            }

            ChattyDivider()
        }
    }

    @ViewBuilder
    private func postBody(_ viewStore: ViewStoreOf<AccountCore>, reader: GeometryProxy) -> some View {
        switch viewStore.postsState {
        case let .loaded(posts):
            if posts.isEmpty {
                InfoView(
                    text: viewStore.isOtherAccount ? "No posts available." : "Let's upload your first post."
                )
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(posts, id: \.id) { post in
                        NavigationLink {
                            PostView(
                                store: Store(
                                    initialState: PostCore.State(
                                        otherAccountId: viewStore.ownAccountId,
                                        ownAccountId: viewStore.accountId,
                                        postState: .loaded(post)
                                    ),
                                    reducer: PostCore()
                                )
                            )
                        } label: {
                            AsyncImage(url: URL(string: post.imageLink)) { image in
                                image
                                    .resizable()
                                    .frame(width: (reader.size.width / 2) - 20, height: (reader.size.width / 2) - 20)
                            } placeholder: {
                                AppColor.lightgray
                            }
                            .frame(width: (reader.size.width / 2) - 20, height: (reader.size.width / 2) - 20)
                        }

                    }
                }
            }

        case .loading, .refreshing:
            LoadingView()

        case .none:
            EmptyView()

        case .error:
            ErrorView(text: "An error occured while fetching your posts...")
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
