//
//  SubscriptionRequestView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.01.23.
//

import SwiftUI
import ComposableArchitecture

struct SubscriptionRequestView: View {

    let store: StoreOf<SubscriptionRequestCore>

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.subscriptionRequestsState {
            case let .loaded(subscriptionRequestAccounts):
                if subscriptionRequestAccounts.isEmpty {
                    InfoView(text: "No subscription requests available.")
                        .onDisappear {
                            viewStore.send(.subscriptionRequestsStateChanged(.none))
                        }
                } else {
                    subscriptionRequestBody(
                        with: subscriptionRequestAccounts,
                        viewStore: viewStore
                    )
                        .refreshable {
                            viewStore.send(.fetchSubscriptionRequests)
                        }
                }

            case .loading, .refreshing, .none:
                LoadingView()
                    .onAppear {
                        if case .none = viewStore.subscriptionRequestsState {
                            viewStore.send(.fetchSubscriptionRequests)
                        }
                    }

            case .error:
                ErrorView(text: "Seems like an error appeared when fetching your subscription requests...") {
                    viewStore.send(.fetchSubscriptionRequests)
                }
            }
        }
        .navigationTitle("Subscription Requests")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func subscriptionRequestBody(with subscriptionRequestAccounts: [Account],
                                         viewStore: ViewStoreOf<SubscriptionRequestCore>) -> some View {
        ScrollView {
            VStack {
                ForEach(subscriptionRequestAccounts, id: \.id) { subscriptionRequestAccount in
                    HStack {
                        ChattyImage(
                            picture: subscriptionRequestAccount.picture,
                            frame: CGSize(width: 30, height: 30)
                        )

                        Text(subscriptionRequestAccount.username)
                            .font(AppFont.body)
                            .foregroundColor(AppColor.black)
                        
                        Spacer()

                        Image(systemSymbol: .checkmarkCircleFill)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(AppColor.success)
                            .onTapGesture {
                                viewStore.send(.acceptSubscription(subscriptionRequestAccount.id))
                            }

                        Image(systemSymbol: .xmarkCircleFill)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(AppColor.error)
                            .onTapGesture {
                                viewStore.send(.declineSubscription(subscriptionRequestAccount.id))
                            }
                    }
                }
            }
            .padding(24)
        }
    }
}
