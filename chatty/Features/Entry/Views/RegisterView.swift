//
//  RegisterView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import SwiftUI

import ComposableArchitecture

struct RegisterView: View {

    let store: Store<RegisterCore.State, RegisterCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                Text("First")
                Text("Second")
                Button(action: {
                    viewStore.send(.showLoginView)
                }, label: {
                    Text("LoginView")
                })
            }
            .tabViewStyle(.page)
        }
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(
            store: .init(
                initialState: RegisterCore.State(),
                reducer: RegisterCore.reducer,
                environment: RegisterCore.Environment(
                    service: RegisterService(),
                    mainScheduler: .main
                )
            )
        )
    }
}
#endif
