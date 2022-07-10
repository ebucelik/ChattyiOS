//
//  LoginView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import SwiftUI

import ComposableArchitecture

struct LoginView: View {

    let store: Store<LoginCore.State, LoginCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                TextField("E-Mail", text: viewStore.binding(\.$login.email))
                TextField("Password", text: viewStore.binding(\.$login.password))
                Button(action: {
                    viewStore.send(.login)
                }, label: {
                    Text("Login")
                })
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store: .init(
                initialState: LoginCore.State(),
                reducer: LoginCore.reducer,
                environment: LoginCore.Environment(
                    service: LoginService(),
                    mainDispatcher: .main,
                    completion: { _ in }
                )
            )
        )
    }
}
