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
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(Array(viewStore.accounts.enumerated()), id: \.offset) { index, account in
                            NavigationLink {
                                AccountView(
                                    store: Store(
                                        initialState: AccountCore.State(
                                            ownAccountId: viewStore.ownAccountId,
                                            ownAccount: viewStore.ownAccount,
                                            accountState: .loaded(account)
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
                            }

                            if viewStore.accounts.count - 1 != index {
                                ChattyDivider()
                            }
                        }
                    }
                    .padding(24)
                }
                .navigationTitle(Text(viewStore.title))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
