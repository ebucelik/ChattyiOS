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
        }
        .onAppear {
            if UserDefaults.standard.data(forKey: "account") == nil {
                showEntryView = true
            }
        }
        .fullScreenCover(isPresented: $showEntryView) {
            LoginView(
                store: .init(
                    initialState: LoginCore.State(),
                    reducer: LoginCore.reducer,
                    environment: LoginCore.Environment(
                        service: LoginService(),
                        mainScheduler: .main,
                        completion: { showHomepage in
                            if showHomepage {
                                self.showEntryView = false
                            }
                        }
                    )
                )
            )
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(
            store: .init(
                initialState: FeedCore.State(),
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
