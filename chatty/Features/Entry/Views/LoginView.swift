//
//  LoginView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import SwiftUI
import SwiftHelper
import ComposableArchitecture

extension BindingViewStore<LoginCore.State> {
    var view: LoginView.ViewState {
        LoginView.ViewState(
            login: self.$login,
            loginState: self.loginState,
            showPassword: self.showPassword,
            isError: self.isError,
            error: self.error
        )
    }
}

struct LoginView: View {
    struct ViewState: Equatable {
        @BindingViewState var login: Login
        var loginState: Loadable<Account>
        var showPassword: Bool
        var isError: Bool
        var error: String
    }

    let store: Store<LoginCore.State, LoginCore.Action>

    var body: some View {
        WithViewStore(store, observe: \.view, send: { .view($0) }) { viewStore in
            stateBody(viewStore)
        }
    }

    @ViewBuilder
    func stateBody(_ viewStore: ViewStore<LoginView.ViewState, LoginCore.Action.View>) -> some View {
        switch viewStore.loginState {
        case .none, .error, .loaded, .loading, .refreshing:
            loginBody(viewStore)
                .onAppear {
                    viewStore.send(.reset)
                }
        }
    }

    @ViewBuilder
    func loginBody(_ viewStore: ViewStore<LoginView.ViewState, LoginCore.Action.View>) -> some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 36)
            
            ChattyIcon()

            Spacer()

            Text("To get started, enter your email and password")
                .font(AppFont.title2.bold())
                .foregroundColor(AppColor.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemSymbol: .personFill)
                        .foregroundColor(AppColor.gray)
                    TextField("Email", text: viewStore.$login.email)
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
                    Image(systemSymbol: .lockFill)
                        .foregroundColor(AppColor.gray)

                    if viewStore.state.showPassword {
                        TextField("Password", text: viewStore.$login.password)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Password", text: viewStore.$login.password)
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                    }

                    Spacer()

                    Button(
                        action: {
                            viewStore.send(.showPassword)
                        }, label: {
                            Image(systemSymbol: viewStore.state.showPassword ? .eyeFill : .eyeSlashFill)
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
                        .font(AppFont.footnote)
                        .foregroundColor(AppColor.gray)

                    Button(action: {
                        viewStore.send(.showRegisterView)
                    }, label: {
                        Text("Sign up now.")
                            .font(AppFont.footnote)
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
                    Image(systemSymbol: .exclamationmarkCircleFill)
                        .foregroundColor(.gray)
                    Text(viewStore.error)
                        .font(AppFont.footnote)
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
            UniversalHelper.resignFirstResponder()
        }
    }
}
