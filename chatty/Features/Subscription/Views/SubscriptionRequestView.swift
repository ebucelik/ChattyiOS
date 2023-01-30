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
                    InfoView(text: "No subscription requests available.") {
                        viewStore.send(.fetchSubscriptionRequests)
                    }
                } else {
                    subscriptionRequestBody(with: subscriptionRequestAccounts)
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
                ErrorView()
            }
        }
        .navigationTitle("Subscription Requests")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func subscriptionRequestBody(with subscriptionRequestAccounts: [Account]) -> some View {
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

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(AppColor.success)

                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(AppColor.error)
                    }
                }
            }
            .padding(24)
        }
    }
}
