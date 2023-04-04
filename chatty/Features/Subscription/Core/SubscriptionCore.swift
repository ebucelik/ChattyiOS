//
//  SubscriptionCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 19.01.23.
//

import ComposableArchitecture

struct SubscriptionCore: ReducerProtocol {

    enum SubscriptionMode {
        case subscriber
        case subscribed
    }

    struct State: Equatable {
        @BindingState
        var showAccountDetails: Bool = false

        let ownAccountId: Int
        let accounts: [Account]
        let title: String
        let info: String

        public init(ownAccountId: Int, accounts: [Account], subscriptionMode: SubscriptionMode) {
            self.ownAccountId = ownAccountId
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

    enum Action: Equatable, BindableAction {
        case showAccountDetails

        case binding(BindingAction<State>)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .showAccountDetails:
            state.showAccountDetails.toggle()

            return .none

        case .binding:
            return .none
        }
    }
}
