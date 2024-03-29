//
//  EntryView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 25.12.22.
//

import SwiftUI
import ComposableArchitecture

struct EntryView: View {

    let store: StoreOf<EntryCore>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.entryViewState {
            case .login:
                loginViewBody()

            case .register:
                registerViewBody()
            }
        }
    }

    @ViewBuilder
    private func registerViewBody() -> some View {
        RegisterView(
            store: store.scope(
                state: \.register,
                action: EntryCore.Action.register
            )
        )
    }

    @ViewBuilder
    private func loginViewBody() -> some View {
        LoginView(
            store: store.scope(
                state: \.login,
                action: EntryCore.Action.login
            )
        )
    }
}
