//
//  SubscriptionView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 18.01.23.
//

import SwiftUI

struct SubscriptionView: View {

    enum SubscriptionMode {
        case subscriber
        case subscribed
    }

    let accounts: [Account]
    let title: String
    let info: String

    init(accounts: [Account], subcriptionMode: SubscriptionMode) {
        self.accounts = accounts

        switch subcriptionMode {
        case .subscriber:
            self.title = "Subscriber"
            self.info = "You have no subscriber."

        case .subscribed:
            self.title = "Subscribed"
            self.info = "You have no user subscribed."
        }
    }

    var body: some View {
        NavigationView {
            if accounts.isEmpty {
                InfoView(info: info)
            } else {
                ScrollView {
                    VStack {
                        ForEach(accounts, id: \.id) { account in
                            HStack {
                                ChattyImage(
                                    picture: account.picture,
                                    frame: CGSize(width: 30, height: 30)
                                )

                                Text(account.username)
                                    .font(AppFont.body)

                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .navigationTitle(Text(title))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
