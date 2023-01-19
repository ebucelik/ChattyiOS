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
        WithViewStore(store) { viewStore in
            if viewStore.accounts.isEmpty {
                InfoView(info: viewStore.info)
            } else {
                ScrollView {
                    VStack {
                        ForEach(viewStore.accounts, id: \.id) { account in
                            NavigationLink {
                                AccountView(
                                    store: Store(
                                        initialState: AccountCore.State(
                                            accountState: .loaded(account),
                                            isOtherAccount: true
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .navigationTitle(Text(viewStore.title))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
