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

    @State
    var isLoading: Bool = false
    @State
    var isError: Bool = false

    var body: some View {
        WithViewStore(store) { viewStore in
            stateBody(viewStore)
        }
    }

    @ViewBuilder
    func stateBody(_ viewStore: ViewStore<LoginCore.State, LoginCore.Action>) -> some View {
        switch viewStore.loginState {
        case .error:
            loginBody(viewStore)
                .onAppear {
                    isLoading = false
                    isError = true
                }

        case .loaded, .none:
            loginBody(viewStore)
                .onAppear {
                    isLoading = false
                    isError = false
                }

        case .loading, .refreshing:
            loginBody(viewStore)
                .onAppear {
                    isLoading = true
                    isError = false
                }
        }
    }

    @ViewBuilder
    func loginBody(_ viewStore: ViewStore<LoginCore.State, LoginCore.Action>) -> some View {
        VStack(spacing: 16) {
            Spacer()

            HStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
                TextField("E-Mail", text: viewStore.binding(\.$login.email))
                    .textContentType(.emailAddress)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.gray, lineWidth: 2)
            )

            HStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                SecureField("Password", text: viewStore.binding(\.$login.password))
                    .textContentType(.password)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.gray, lineWidth: 2)
            )

            Button(action: {

            }, label: {
                Text("Don't have an account? Sign up now.")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
            })
            .padding(.horizontal)
            .padding(.bottom)

            VStack {
                Divider()

                HStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Username or password is invalid.")
                        .font(.footnote)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .opacity(isError ? 1 : 0)

            Spacer()

            Button(action: {
                viewStore.send(.login)
            }, label: {
                VStack {
                    if viewStore.loginState == .loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                    } else {
                        Text("LOGIN")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(.blue)
                .cornerRadius(8)
            })
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                    mainScheduler: .main,
                    completion: { _ in }
                )
            )
        )
    }
}
