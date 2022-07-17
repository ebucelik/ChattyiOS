//
//  FeedView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI

import ComposableArchitecture

struct FeedView: View {

    let store: Store<FeedCore.State, FeedCore.Action>

    @State
    var showEntryView = false

    @State
    var showRegisterView = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Hi")
                Text("Ebu")
                Text("BSc")
                Button(action: {
                    viewStore.send(.logout)
                }, label: {
                    Text("Logout")
                })
            }
            .fullScreenCover(isPresented: $showEntryView) {
                if !viewStore.showRegisterView {
                    LoginView(
                        store: store.scope(
                            state: \.login,
                            action: FeedCore.Action.login
                        )
                    )
                } else {
                    RegisterView(
                        store: store.scope(
                            state: \.register,
                            action: FeedCore.Action.register
                        )
                    )
                }
            }
        }
        .onAppear {
            if UserDefaults.standard.data(forKey: "account") == nil {
                showEntryView = true
            }
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(
            store: .init(
                initialState: FeedCore.State(
                    login: LoginCore.State(),
                    register: RegisterCore.State()
                ),
                reducer: FeedCore.reducer,
                environment: FeedCore.Environment(
                    service: LogoutService(),
                    mainScheduler: .main
                )
            )
        )
    }
}
#endif
