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
            TabView(selection: viewStore.binding(get: \.tabSelection, send: .nextTab(nil))) {
                provideUsername(viewStore)
                    .tag(0)
                provideEmailAndPassword(viewStore)
                    .tag(1)
                Button(
                    action: {
                        viewStore.send(.showLoginView)
                    }, label: {
                        Text("LoginView")
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .onAppear {
                UIScrollView.appearance().isScrollEnabled = false

                viewStore.send(.reset)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    @ViewBuilder
    func provideUsername(_ viewStore: RegisterViewStore) -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .foregroundColor(Colors.gray)
                        TextField("Username", text: viewStore.binding(\.$register.username))
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .onChange(of: viewStore.register.username) { _ in
                                viewStore.send(.checkUsername)
                            }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Colors.gray, lineWidth: 2)
                    )


                    switch viewStore.accountAvailabilityState {
                    case .loading, .refreshing:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 30, height: 30, alignment: .center)

                    case .none:
                        EmptyView()

                    case .loaded:
                        if viewStore.isAccountAvailable {
                            Image(systemName: "checkmark.seal.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Colors.success)
                        } else {
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Colors.error)
                        }

                    case .error:
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Colors.error)
                    }
                }

                Button(action: {
                    viewStore.send(.showLoginView)
                }, label: {
                    Text("Already have an account? Sign in now.")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Colors.gray)
                })
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()

            if case .loaded = viewStore.accountAvailabilityState, viewStore.isAccountAvailable {
                Button(
                    action: {
                        viewStore.send(.nextTab(viewStore.tabSelection + 1))
                    }, label: {
                        Text("Wonderful!\nLet's go to the next page")
                            .font(.title)
                            .bold()
                            .italic()
                            .foregroundColor(Colors.button)
                            .frame(alignment: .center)
                            .textCase(.uppercase)
                            .padding()
                    }
                )
            }
        }
    }

    @ViewBuilder
    func provideEmailAndPassword(_ viewStore: RegisterViewStore) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "envelope.fill")
                    .foregroundColor(Colors.gray)
                TextField("E-Mail", text: viewStore.binding(\.$register.email))
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onChange(of: viewStore.register.email) { _ in
                        viewStore.send(.checkIfEmailIsValid)
                    }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Colors.gray, lineWidth: 2)
            )

            HStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .foregroundColor(Colors.gray)

                if viewStore.state.showPassword {
                    TextField("Password", text: viewStore.binding(\.$register.password))
                        .textContentType(.newPassword)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onChange(of: viewStore.register.password) { _ in
                            viewStore.send(.checkPassword)
                        }
                } else {
                    SecureField("Password", text: viewStore.binding(\.$register.password))
                        .textContentType(.newPassword)
                        .textInputAutocapitalization(.never)
                        .onChange(of: viewStore.register.password) { _ in
                            viewStore.send(.checkPassword)
                        }
                }

                Spacer()

                Button(
                    action: {
                        viewStore.send(.showPassword)
                    }, label: {
                        Image(systemName: viewStore.state.showPassword ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(Colors.gray)
                    }
                )
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Colors.gray, lineWidth: 2)
            )

            VStack {
                Divider()

                HStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(viewStore.error)
                        .font(.footnote)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .opacity(viewStore.isError ? 1 : 0)

            if case .loaded = viewStore.accountAvailabilityState, viewStore.isEmailAndPasswordValid {
                Button(
                    action: {
                        viewStore.send(.nextTab(viewStore.tabSelection + 1))
                    }, label: {
                        Text("Coolio. Just one step is missing ...")
                            .font(.title)
                            .bold()
                            .italic()
                            .foregroundColor(Colors.button)
                            .frame(alignment: .center)
                            .textCase(.uppercase)
                            .padding()
                    }
                )
            }
        }
        .padding()
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
