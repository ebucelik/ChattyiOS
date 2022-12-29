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

            Text("To get started, enter your email and password")
                .font(.title2.bold())
                .foregroundColor(AppColor.button)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppColor.gray)
                    TextField("Email", text: viewStore.binding(\.$login.email))
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(AppColor.gray, lineWidth: 2)
                )

                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppColor.gray)

                    if viewStore.state.showPassword {
                        TextField("Password", text: viewStore.binding(\.$login.password))
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Password", text: viewStore.binding(\.$login.password))
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                    }

                    Spacer()

                    Button(
                        action: {
                            viewStore.send(.showPassword)
                        }, label: {
                            Image(systemName: viewStore.state.showPassword ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(AppColor.gray)
                        }
                    )
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(AppColor.gray, lineWidth: 2)
                )

                HStack(spacing: 5) {
                    Text("Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(AppColor.gray)

                    Button(action: {
                        viewStore.send(.showRegisterView)
                    }, label: {
                        Text("Sign up now.")
                            .font(.footnote)
                            .bold()
                            .foregroundColor(AppColor.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                }
                .padding(.horizontal)
                .padding(.bottom)
            }

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
                text: "Log in",
                isLoading: viewStore.loginState == .loading,
                action: {
                    viewStore.send(.login)
                }
            )
        }
        .padding()
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
