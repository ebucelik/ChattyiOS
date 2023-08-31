//
//  SubscriptionView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 18.01.23.
//

import SwiftUI
import ComposableArchitecture

struct SubscriptionView: View {

    let store: StoreOf<SubscriptionCore>

    init(store: StoreOf<SubscriptionCore>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.accounts.isEmpty {
                InfoView(text: viewStore.info)
            } else {
                List(
                    viewStore.accounts,
                    rowContent: { account in
                        NavigationLink {
                            AccountView(
                                store: Store(
                                    initialState: AccountCore.State(
                                        ownAccountId: viewStore.ownAccountId,
                                        ownAccount: viewStore.ownAccount,
                                        accountState: .loaded(account),
                                        isSubscriberView: true
                                    ),
                                    reducer: {
                                        AccountCore()
                                    }
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
                            .padding(.vertical, 4)
                        }
                    }
                )
                .navigationTitle(Text(viewStore.title))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
