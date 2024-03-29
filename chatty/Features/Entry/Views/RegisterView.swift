//
//  RegisterView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import SwiftUI

import ComposableArchitecture
import SwiftHelper

extension BindingViewStore<RegisterCore.State> {
    var view: RegisterView.ViewState {
        RegisterView.ViewState(
            registerState: self.registerState,
            usernameAvailableState: self.usernameAvailableState,
            emailAvailableState: self.emailAvailableState,
            passwordValidState: self.passwordValidState,
            showPassword: self.showPassword,
            viewState: self.viewState,
            picture: self.picture,
            register: self.$register,
            error: self.error,
            isUsernameAvailable: self.isUsernameAvailable,
            isEmailAndPasswordValid: self.isEmailAndPasswordValid,
            textMaxLength: self.textMaxLength,
            approachesMaxLength: self.approachesMaxLength,
            termsAndConditionsAccepted: self.termsAndConditionsAccepted,
            showTermsAndConditionsWebView: self.showTermsAndConditionsWebView,
            showEulaWebView: self.showEulaWebView
        )
    }
}

struct RegisterView: View {

    struct ViewState: Equatable {
        var registerState: Loadable<Account>
        var usernameAvailableState: Loadable<Bool>
        var emailAvailableState: Loadable<Bool>
        var passwordValidState: Loadable<Bool>
        var showPassword: Bool
        var viewState: RegisterCore.ViewState
        var picture: UIImage?
        @BindingViewState var register: Register
        var error: String
        var isUsernameAvailable: Bool
        var isEmailAndPasswordValid: Bool
        var textMaxLength: Int
        var approachesMaxLength: Bool
        var termsAndConditionsAccepted: Bool
        var showTermsAndConditionsWebView: Bool
        var showEulaWebView: Bool
    }

    typealias RegisterViewStore = ViewStore<RegisterView.ViewState, RegisterCore.Action.View>
    let store: Store<RegisterCore.State, RegisterCore.Action>
    let imagePickerController = ImagePickerController(placeholder: "person.crop.circle.fill")

    var body: some View {
        WithViewStore(store, observe: \.view, send: { .view($0) }) { viewStore in
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
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showTermsAndConditionsWebView,
                    send: { .setShowTermsAndConditionsWebView($0) })
            ) {
                WebView(url: URL(string: "https://main--helpful-naiad-524c37.netlify.app/terms.html")!)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showEulaWebView,
                    send: { .setEulaWebView($0) })
            ) {
                WebView(url: URL(string: "https://main--helpful-naiad-524c37.netlify.app/eula.html")!)
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

                        TextField("Username", text: viewStore.$register.username)
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

                        TextField("E-Mail", text: viewStore.$register.email)
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

                        if viewStore.showPassword {
                            TextField("Password", text: viewStore.$register.password)
                                .textContentType(.newPassword)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onChange(of: viewStore.register.password) { _ in
                                    viewStore.send(.checkPassword)
                                }
                        } else {
                            SecureField("Password", text: viewStore.$register.password)
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
                                Image(systemSymbol: viewStore.showPassword ? .eyeFill : .eyeSlashFill)
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
            provideProfilePictureHeader(viewStore)

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

            HStack(spacing: 16) {
                HStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        TextField(
                            "Your bio",
                            text: viewStore.$register.biography,
                            axis: .vertical
                        )
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 35)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Text("\(viewStore.register.biography.count)/\(viewStore.textMaxLength)")
                            .foregroundColor(viewStore.approachesMaxLength ? AppColor.error : AppColor.primary)
                            .font(viewStore.approachesMaxLength ? .caption.bold() : .caption)
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(AppColor.gray, lineWidth: 2)
                )
            }

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
            .disabled(!viewStore.termsAndConditionsAccepted)
            .opacity(viewStore.termsAndConditionsAccepted ? 1 : 0.8)

            Toggle(
                isOn: viewStore.binding(
                    get: \.termsAndConditionsAccepted,
                    send: { .setTermsAndConditions($0) }
                )
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("By checking this box, you are agreeing to our ")
                        .font(AppFont.caption)
                    HStack(spacing: 4) {
                        Text("terms of service")
                            .font(AppFont.caption)
                            .bold()
                            .foregroundColor(AppColor.primary)
                            .onTapGesture {
                                viewStore.send(.setShowTermsAndConditionsWebView(true))
                            }

                        Text("and")
                            .font(AppFont.caption)

                        Text("EULA.")
                            .font(AppFont.caption)
                            .bold()
                            .foregroundColor(AppColor.primary)
                            .onTapGesture {
                                viewStore.send(.setEulaWebView(true))
                            }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private func provideProfilePictureHeader(_ viewStore: RegisterViewStore) -> some View {
        HStack {
            Button(action: { viewStore.send(.showEmailAndPasswordView) }) {
                Text("Back")
                    .bold()
                    .foregroundColor(AppColor.gray)
            }
            .disabled(.loading == viewStore.registerState)

            Spacer()
        }

        Spacer()

        Text("Welcome \(viewStore.register.username)")
            .font(AppFont.title2)
            .bold()
            .frame(maxWidth: .infinity, alignment: .center)

        Spacer()
    }
}
