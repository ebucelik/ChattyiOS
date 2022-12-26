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
        WithViewStore(store) { viewStore in
            if viewStore.showRegister {
                registerViewBody()
            } else {
                loginViewBody()
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

#if DEBUG
struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(
            store: Store(
                initialState: EntryCore.State(),
                reducer: EntryCore()
            )
        )
    }
}
#endif
