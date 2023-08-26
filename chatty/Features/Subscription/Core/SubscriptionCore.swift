//
//  SubscriptionCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 19.01.23.
//

import ComposableArchitecture

struct SubscriptionCore: Reducer {

    enum SubscriptionMode {
        case subscriber
        case subscribed
    }

    struct State: Equatable {
        var ownAccountId: Int
        var ownAccount: Account?
        var accounts: [Account]
        var title: String
        var info: String

        public init(ownAccountId: Int,
                    ownAccount: Account?,
                    accounts: [Account],
                    subscriptionMode: SubscriptionMode) {
            self.ownAccountId = ownAccountId
            self.ownAccount = ownAccount
            self.accounts = accounts

            switch subscriptionMode {
            case .subscriber:
                self.title = "Subscriber"
                self.info = "You have no subscriber."

            case .subscribed:
                self.title = "Subscribed"
                self.info = "You have no user subscribed."
            }
        }
    }

    enum Action: Equatable {}

    func reduce(into state: inout State, action: Action) -> Effect<Action> {}
}
