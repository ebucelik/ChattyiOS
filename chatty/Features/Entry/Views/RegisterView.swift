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
            ZStack {
                if viewStore.showUsernameView {
                    provideUsername(viewStore)
                }

                if viewStore.showEmailAndPasswordView {
                    provideEmailAndPassword(viewStore)
                }

                if viewStore.showProfilePictureView {
                    provideProfilePicture(viewStore)
                }
            }
            .onAppear {
                viewStore.send(.reset)
            }
            .onDisappear {
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
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 36)

            ChattyIcon()

            Spacer()

            Text("In the first step, enter your username")
                .font(.title2.bold())
                .foregroundColor(AppColor.button)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .foregroundColor(AppColor.gray)

                        TextField("Username", text: viewStore.binding(\.$register.username))
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .onChange(of: viewStore.register.username) { _ in
                                viewStore.send(.checkUsername)
                            }
                            .onAppear {
                                if !viewStore.register.username.isEmpty {
                                    viewStore.send(.checkUsername)
                                }
                            }

                        Spacer()

                        availabilityCheck(for: viewStore.usernameAvailableState)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(AppColor.gray, lineWidth: 2)
                    )
                }

                HStack(spacing: 5) {
                    Text("Already have an account?")
                        .font(.footnote)
                        .foregroundColor(AppColor.gray)

                    Button(action: {
                        viewStore.send(.showLoginView)
                    }, label: {
                        Text("Sign in now.")
                            .font(.footnote)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(AppColor.gray)
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
            .opacity(viewStore.error.isEmpty ? 0 : 1)

            Spacer()

            ChattyButton(text: "Step 2", action: { viewStore.send(.showEmailAndPasswordView) })
                .opacity(viewStore.isUsernameAvailable ? 1 : 0)
        }
        .padding()
    }

    @ViewBuilder
    func provideEmailAndPassword(_ viewStore: RegisterViewStore) -> some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { viewStore.send(.showUsernameView) }) {
                    Text("Back")
                        .bold()
                        .foregroundColor(AppColor.gray)
                }

                Spacer()
            }

            ChattyIcon()

            Spacer()

            Text("Enter your email and password")
                .font(.title2.bold())
                .foregroundColor(AppColor.button)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(AppColor.gray)

                        TextField("E-Mail", text: viewStore.binding(\.$register.email))
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .onChange(of: viewStore.register.email) { _ in
                                viewStore.send(.checkIfEmailIsValid)
                            }

                        Spacer()

                        availabilityCheck(for: viewStore.emailAvailableState)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(AppColor.gray, lineWidth: 2)
                    )
                }

                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(AppColor.gray)

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
                                    .foregroundColor(AppColor.gray)
                            }
                        )

                        availabilityCheck(for: viewStore.passwordValidState)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(AppColor.gray, lineWidth: 2)
                    )
                }
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
            .opacity(viewStore.error.isEmpty ? 0 : 1)

            Spacer()

            ChattyButton(text: "Just one step is missing", action: { viewStore.send(.showProfilePictureView) })
                .opacity(viewStore.isEmailAndPasswordValid ? 1 : 0)
        }
        .padding()
    }

    @ViewBuilder
    func provideProfilePicture(_ viewStore: RegisterViewStore) -> some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { viewStore.send(.showEmailAndPasswordView) }) {
                    Text("Back")
                        .bold()
                        .foregroundColor(AppColor.gray)
                }

                Spacer()

                Button(action: { viewStore.send(.register) }) {
                    Text("Skip")
                        .bold()
                        .foregroundColor(AppColor.error)
                }
            }

            Spacer()

            Text("Welcome \(viewStore.register.username)")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            getImage(from: viewStore.picture)
                .resizable()
                .frame(width: 150, height: 150, alignment: .center)
                .foregroundColor(AppColor.gray)
                .cornerRadius(75)
                .shadow(radius: 10)
                .onTapGesture {
                    viewStore.send(.showImagePicker)
                }

            Spacer()
                .frame(height: 50)

            Text("You're all set!")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Take a minute to upload a profile photo.")
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            ChattyButton(text: "Start with Chatty", action: { viewStore.send(.register) })
                .opacity(viewStore.picture != nil ? 1 : 0)
        }
        .sheet(isPresented: viewStore.binding(\.$showImagePicker)) {
            ImagePicker(image: viewStore.binding(\.$picture))
        }
        .padding()
    }

    private func getImage(from uiImage: UIImage?) -> Image {
        if let uiImage = uiImage {
            return Image(uiImage: uiImage)
        }

        return Image(systemName: "person.crop.circle.fill")
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(
            store: Store(
                initialState: RegisterCore.State(),
                reducer: RegisterCore()
            )
        )
    }
}
#endif
