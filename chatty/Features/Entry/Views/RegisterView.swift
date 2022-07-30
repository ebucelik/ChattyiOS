//
//  RegisterView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import SwiftUI

import ComposableArchitecture
import SwiftHelper

struct RegisterView: View {

    typealias RegisterViewStore = ViewStore<RegisterCore.State, RegisterCore.Action>
    let store: Store<RegisterCore.State, RegisterCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                provideUsername(viewStore)
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

    @ViewBuilder
    func provideUsername(_ viewStore: RegisterViewStore) -> some View {
        HStack {
            HStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .foregroundColor(Colors.gray)
                TextField("Username", text: viewStore.binding(\.$register.username))
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Colors.gray, lineWidth: 2)
            )

            Button(
                action: {
                    viewStore.send(.checkUsername)
                }, label: {
                    Image(systemName: "arrow.right")
                        .foregroundColor(Colors.button)
                }
            )
        }.padding()
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
                    accountAvailabilityService: AccountAvailabilityService(),
                    mainScheduler: .main
                )
            )
        )
    }
}
#endif
