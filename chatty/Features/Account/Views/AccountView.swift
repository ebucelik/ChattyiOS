//
//  AccountView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI
import ComposableArchitecture
import SwiftHelper
import CachedAsyncImage

extension BindingViewStore<AccountCore.State> {
    var view: AccountView.ViewState {
        AccountView.ViewState(
            ownAccountId: self.ownAccountId,
            accountState: self.accountState,
            subscriberState: self.subscribedState,
            subscribedState: self.subscribedState,
            subscribeState: self.subscribeState,
            subscriptionInfoState: self.subscriptionInfoState,
            postsState: self.postsState,
            subscriptionRequestCoreState: self.subscriptionRequestCoreState,
            isOtherAccount: self.isOtherAccount,
            accountId: self.accountId,
            newUpdatesAvailable: self.newUpdatesAvailable,
            showMore: self.showMore,
            showDeleteAlert: self.$showDeleteAlert,
            showPrivacyPolicyWebView: self.showPrivacyPolicyWebView,
            isSubscribed: self.isSubscribed,
            isSubscriberView: self.isSubscriberView,
            showBuyMeACoffeeWebView: self.showBuyMeACoffeeWebView
        )
    }
}

struct AccountView: View {

    struct ViewState: Equatable {
        var ownAccountId: Int?
        var accountState: Loadable<Account>
        var subscriberState: Loadable<[Account]>
        var subscribedState: Loadable<[Account]>
        var subscribeState: Loadable<Subscriber>
        var subscriptionInfoState: Loadable<SubscriptionInfo>
        var postsState: Loadable<[Post]>
        var subscriptionRequestCoreState: SubscriptionRequestCore.State?
        var isOtherAccount: Bool
        var accountId: Int?
        var newUpdatesAvailable: Bool
        var showMore: Bool
        @BindingViewState var showDeleteAlert: Bool
        var showPrivacyPolicyWebView: Bool
        var isSubscribed: Bool
        var isSubscriberView: Bool
        var showBuyMeACoffeeWebView: Bool
    }

    typealias AccountViewStore = ViewStore<AccountView.ViewState, AccountCore.Action.View>

    let store: StoreOf<AccountCore>

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @Environment(\.dismiss) var dismiss

//    @StateObject var inAppStore: InAppStore = InAppStore()

    var body: some View {
        WithViewStore(store, observe: \.view, send: { .view($0) }) { viewStore in
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
                                viewStore.send(.toggleNewUpdatesAvailable)
                                viewStore.send(.fetchAccount)
                            }
                        }
                        .navigationTitle(account.username)

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
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showMore,
                    send: { .showMore($0) }
                )
            ) {
                MoreView(
                    isOtherAccount: viewStore.isOtherAccount,
                    onLogoutTap: { viewStore.send(.logout) },
                    onDeleteAccountTap: { viewStore.send(.didDeleteAccountTapped) },
                    deleteAccount: { viewStore.send(.didDeleteAccount) },
                    showDeleteAlert: viewStore.$showDeleteAlert,
                    onBuyMeACoffeTap: { viewStore.send(.setShowBuyMeACoffeeWebView(true)) },
                    onPrivacyPolicyTap: { viewStore.send(.setShowPrivacyPolicyWebView(true)) },
                    onBlockAccountTap: {
                        viewStore.send(.blockAccount)

                        dismiss()
                    }
                )
//                .environmentObject(inAppStore)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showPrivacyPolicyWebView,
                    send: { .setShowPrivacyPolicyWebView($0) })
            ) {
                WebView(url: URL(string: "https://main--helpful-naiad-524c37.netlify.app")!)
                    .onDisappear {
                        viewStore.send(.setShowPrivacyPolicyWebView(false))
                    }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showBuyMeACoffeeWebView,
                    send: { .setShowBuyMeACoffeeWebView($0) })
            ) {
                WebView(url: URL(string: "https://www.buymeacoffee.com/celikebu")!)
                    .onDisappear {
                        viewStore.send(.setShowBuyMeACoffeeWebView(false))
                    }
            }
        }
    }

    @ViewBuilder
    private func accountBody(with account: Account, _ viewStore: AccountViewStore) -> some View {
        GeometryReader { reader in
            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    if viewStore.isOtherAccount {
                        VStack(spacing: 24) {
                            ChattyImage(
                                picture: account.picture,
                                frame: CGSize(width: 125, height: 125)
                            )

                            VStack(spacing: 10) {
                                Text(account.biography)
                                    .font(AppFont.headline)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(AppColor.black)
                        }
                    } else {
                        NavigationLink {
                            ProfilePictureView(
                                store: store.scope(
                                    state: \.profilePictureCoreState,
                                    action: AccountCore.Action.profilePicture
                                )
                            )
                        } label: {
                            VStack(spacing: 24) {
                                ZStack {
                                    ChattyImage(
                                        picture: account.picture,
                                        frame: CGSize(width: 125, height: 125)
                                    )

                                    VStack {
                                        HStack {
                                            Spacer()

                                            Image(systemSymbol: .squareAndPencilCircleFill)
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .tint(AppColor.primary)
                                        }

                                        Spacer()
                                    }
                                    .frame(width: 115, height: 115)
                                }

                                VStack(spacing: 10) {
                                    Text(account.biography)
                                        .font(AppFont.headline)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColor.black)
                            }
                        }
                    }

                    HStack(spacing: 16) {
                        NavigationLink {
                            SubscriptionView(
                                store: store.scope(
                                    state: \.subscriberCoreState,
                                    action: AccountCore.Action.subscription
                                )
                            )
                        } label: {
                            Group {
                                VStack(spacing: 10) {
                                    Text("Subscriber")
                                        .font(AppFont.caption)

                                    Text(String(account.subscriberCount))
                                        .font(AppFont.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.leading)
                                .foregroundColor(AppColor.black)
                            }
                        }
                        .disabled(viewStore.isOtherAccount)

                        NavigationLink {
                            SubscriptionView(
                                store: store.scope(
                                    state: \.subscribedCoreState,
                                    action: AccountCore.Action.subscription
                                )
                            )
                        } label: {
                            Group {
                                VStack(spacing: 10) {
                                    Text("Subscribed")
                                        .font(AppFont.caption)

                                    Text(String(account.subscribedCount))
                                        .font(AppFont.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColor.black)
                            }
                        }
                        .disabled(viewStore.isOtherAccount)

                        VStack(spacing: 10) {
                            Text("Posts")
                                .font(AppFont.caption)

                            Text(String(account.postCount))
                                .font(AppFont.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing)
                    }

                    subscriptionBody(viewStore)

                    postBody(viewStore, reader: reader)
                }
                .padding()
                .padding(.top, 24)
                .toolbar {
                    if viewStore.isSubscribed && !viewStore.isSubscriberView {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image(systemSymbol: .line3HorizontalCircleFill)
                                .foregroundColor(AppColor.primary)
                                .onTapGesture {
                                    viewStore.send(.showMore(true))
                                }
                        }
                    } else if !viewStore.isOtherAccount {
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
                                Image(systemSymbol: .personFillBadgePlus)
                                    .foregroundColor(AppColor.primary)
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image(systemSymbol: .line3HorizontalCircleFill)
                                .foregroundColor(AppColor.primary)
                                .onTapGesture {
                                    viewStore.send(.showMore(true))
                                }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    @ViewBuilder
    private func subscriptionBody(_ viewStore: AccountViewStore) -> some View {
        if viewStore.isOtherAccount {
            switch viewStore.subscriptionInfoState {
            case let .loaded(subscriptionInfo):
                ChattyButton(
                    text: subscriptionInfo.status,
                    backgroundColor: subscriptionInfo.accepted ? nil : AppColor.gray,
                    action: { viewStore.send(.declineOrCancelSubscriptionRequest) }
                )
                .padding(.horizontal)

            case .loading, .refreshing:
                ChattyButton(
                    isLoading: true,
                    action: {}
                )
                .padding(.horizontal)

            case .none:
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
        }
    }

    @ViewBuilder
    private func postBody(_ viewStore: AccountViewStore, reader: GeometryProxy) -> some View {
        switch viewStore.postsState {
        case let .loaded(posts):
            if posts.isEmpty {
                InfoView(
                    text: viewStore.isOtherAccount ? "nopostsavailable" : "uploadfirstpost"
                )
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(posts, id: \.id) { post in
                        NavigationLink {
                            GeometryReader { reader in
                                ScrollView {
                                    PostView(
                                        store: Store(
                                            initialState: PostCore.State(
                                                otherAccountId: viewStore.ownAccountId,
                                                ownAccountId: viewStore.accountId,
                                                postState: .loaded(post)
                                            ),
                                            reducer: {
                                                PostCore()
                                            }
                                        ),
                                        size: reader.size
                                    )
                                }
                            }
                        } label: {
                            CachedAsyncImage(url: URL(string: post.imageLink), urlCache: .imageCache) { image in
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
