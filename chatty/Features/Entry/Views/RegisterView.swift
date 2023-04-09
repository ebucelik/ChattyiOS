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
    let imagePickerController = ImagePickerController(placeholder: "person.crop.circle.fill")

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                switch viewStore.viewState {
                case .usernameView:
                    provideUsername(viewStore)

                case .emailAndPasswordView:
                    provideEmailAndPassword(viewStore)

                case .profilePictureView:
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
                UniversalHelper.resignFirstResponder()
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
                .font(AppFont.title2.bold())
                .foregroundColor(AppColor.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemSymbol: .personFill)
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
                        .font(AppFont.footnote)
                        .foregroundColor(AppColor.gray)

                    Button(action: {
                        viewStore.send(.showLoginView)
                    }, label: {
                        Text("Sign in now.")
                            .font(AppFont.footnote)
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
                    Image(systemSymbol: .exclamationmarkCircleFill)
                        .foregroundColor(.gray)
                    Text(viewStore.error)
                        .font(AppFont.footnote)
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
                .font(AppFont.title2.bold())
                .foregroundColor(AppColor.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemSymbol: .envelopeFill)
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
                        Image(systemSymbol: .lockFill)
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
                                Image(systemSymbol: viewStore.state.showPassword ? .eyeFill : .eyeSlashFill)
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
                    Image(systemSymbol: .exclamationmarkCircleFill)
                        .foregroundColor(.gray)
                    Text(viewStore.error)
                        .font(AppFont.footnote)
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
                .disabled(.loading == viewStore.registerState)

                Spacer()

                Button(action: { viewStore.send(.register) }) {
                    Text("Skip")
                        .bold()
                        .foregroundColor(AppColor.error)
                }
                .disabled(.loading == viewStore.registerState)
                .opacity(viewStore.picture != nil ? 0 : 1)
            }

            Spacer()

            Text("Welcome \(viewStore.register.username)")
                .font(AppFont.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            ViewControllerRepresentable(
                viewController: imagePickerController
            )
            .frame(width: 150, height: 150, alignment: .center)
            .cornerRadius(75)
            .onAppear {
                imagePickerController.onImagePicked = { pickedImage in
                    viewStore.send(.setImage(pickedImage))
                }
            }
            .disabled(.loading == viewStore.registerState)

            Spacer()
                .frame(height: 50)

            Text("You're all set!")
                .font(AppFont.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Take a minute to upload a profile picture.")
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()

            ChattyButton(
                text: "Start with Chatty",
                isLoading: .loading == viewStore.registerState,
                action: { viewStore.send(.register) }
            )
            .opacity(viewStore.picture != nil ? 1 : 0)
        }
        .padding()
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
