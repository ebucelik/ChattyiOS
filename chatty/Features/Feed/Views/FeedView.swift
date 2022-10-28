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

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        ForEach(0...50, id: \.self) { _ in
                            PostView()

                            Divider()
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: viewStore.binding(get: \.showEntryView, send: .showEntryView(nil))) {
                if viewStore.showRegisterView {
                    RegisterView(
                        store: store.scope(
                            state: \.register,
                            action: FeedCore.Action.register
                        )
                    )
                } else {
                    LoginView(
                        store: store.scope(
                            state: \.login,
                            action: FeedCore.Action.login
                        )
                    )
                }
            }
            .onAppear {
                if UserDefaults.standard.data(forKey: "account") == nil {
                    viewStore.send(.showEntryView(true))
                }
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
