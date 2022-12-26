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
            stateBody(viewStore)
        }
    }

    @ViewBuilder
    func stateBody(_ viewStore: ViewStore<LoginCore.State, LoginCore.Action>) -> some View {
        switch viewStore.loginState {
        case .none, .error, .loaded, .loading, .refreshing:
            loginBody(viewStore)
                .onAppear {
                    viewStore.send(.reset)
                }
        }
    }

    @ViewBuilder
    func loginBody(_ viewStore: ViewStore<LoginCore.State, LoginCore.Action>) -> some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 36)
            
            ChattyIcon()

            Spacer()

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .foregroundColor(Colors.gray)
                    TextField("E-Mail", text: viewStore.binding(\.$login.email))
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Colors.gray, lineWidth: 2)
                )

                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Colors.gray)
                    SecureField("Password", text: viewStore.binding(\.$login.password))
                        .textContentType(.password)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Colors.gray, lineWidth: 2)
                )

                HStack(spacing: 5) {
                    Text("Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(Colors.gray)

                    Button(action: {
                        viewStore.send(.showRegisterView)
                    }, label: {
                        Text("Sign up now.")
                            .font(.footnote)
                            .bold()
                            .foregroundColor(Colors.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.horizontal)

            VStack {
                ChattyDivider()

                HStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.gray)
                    Text(viewStore.error)
                        .font(.footnote)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .opacity(viewStore.isError ? 1 : 0)

            Spacer()

            ChattyButton(
                text: "LOGIN",
                isLoading: viewStore.loginState == .loading,
                action: {
                    viewStore.send(.login)
                }
            )
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store: Store(
                initialState: LoginCore.State(),
                reducer: LoginCore()
            )
        )
    }
}
#endif
