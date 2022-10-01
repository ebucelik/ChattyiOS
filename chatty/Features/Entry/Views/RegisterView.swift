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
                provideProfilePicture(viewStore)
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
            Spacer()

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

                    availabilityCheck(for: viewStore.usernameAvailableState)
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

            VStack {
                Divider()

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

            provideButton(text: "Slide to next page", action: { viewStore.send(.nextTab(viewStore.tabSelection + 1)) })
                .opacity(viewStore.isUsernameAvailable ? 1 : 0)
                .padding()

            Spacer()
                .frame(height: 30)
        }
    }

    @ViewBuilder
    func provideEmailAndPassword(_ viewStore: RegisterViewStore) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Group {
                HStack(spacing: 16) {
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

                    availabilityCheck(for: viewStore.emailAvailableState)
                }

                HStack(spacing: 16) {
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

                    availabilityCheck(for: viewStore.passwordValidState)
                }
            }

            VStack {
                Divider()

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

            provideButton(text: "Just one step is missing", action: { viewStore.send(.nextTab(viewStore.tabSelection + 1)) })
                .opacity(viewStore.isEmailAndPasswordValid ? 1 : 0)

            Spacer()
                .frame(height: 30)
        }
        .padding()
    }

    @ViewBuilder
    func provideProfilePicture(_ viewStore: RegisterViewStore) -> some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()

                Button(action: { viewStore.send(.showHomepage) }) {
                    Text("Skip")
                        .bold()
                        .foregroundColor(Colors.error)
                }
            }
            .padding()

            Spacer()

            Text("Welcome \(viewStore.register.username)")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            if let selectedPhoto = viewStore.profilePhoto {
                Image(uiImage: selectedPhoto)
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
                    .foregroundColor(Colors.gray)
                    .cornerRadius(75)
                    .shadow(radius: 10)
                    .onTapGesture {
                        viewStore.send(.showImagePicker)
                    }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
                    .foregroundColor(Colors.gray)
                    .shadow(radius: 10)
                    .onTapGesture {
                        viewStore.send(.showImagePicker)
                    }
            }

            Spacer()
                .frame(height: 50)

            Text("You're all set")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Take a minute to upload a profile photo.")
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            provideButton(text: "Start with Chatty", action: { viewStore.send(.showHomepage) })
                .opacity(viewStore.profilePhoto != nil ? 1 : 0)
                .padding(.bottom, 30)
        }
        .sheet(isPresented: viewStore.binding(\.$showImagePicker)) {
            ImagePicker(image: viewStore.binding(\.$profilePhoto))
        }
        .padding()
    }
}

extension View {
    @ViewBuilder
    func availabilityCheck(for loadable: Loadable<Bool>) -> some View {
        switch loadable {
        case .loading, .refreshing:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(width: 30, height: 30, alignment: .center)

        case .error:
            Image(systemName: "x.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Colors.error)

        case let .loaded(available):
            if available {
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

        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    func provideButton(text: String, action: @escaping () -> Void) -> some View {
        VStack {
            Button(action: action) {
                Text(text)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()

            }
        }
        .background(Colors.button)
        .cornerRadius(8)
        .shadow(radius: 5)
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
