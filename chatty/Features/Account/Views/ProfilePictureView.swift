//
//  ProfilePictureView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 25.08.23.
//

import SwiftUI
import ComposableArchitecture

struct ProfilePictureView: View {

    @Environment(\.dismiss) var dismiss

    let imagePickerController = ImagePickerController(placeholder: "")
    let store: StoreOf<ProfilePictureCore>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack {
                    ZStack {
                        if viewStore.pickedImage == nil {
                            ChattyImage(
                                picture: viewStore.account.picture,
                                frame: CGSize(width: 125, height: 125)
                            )
                        }

                        ViewControllerRepresentable(
                            viewController: imagePickerController
                        )
                        .frame(width: 125, height: 125, alignment: .center)
                        .cornerRadius(62.5)
                        .onAppear {
                            imagePickerController.onImagePicked = { pickedImage in
                                viewStore.send(.didImagePicked(pickedImage))
                            }
                        }
                        .disabled(.loading == viewStore.accountState)
                    }

                    Spacer()
                        .frame(height: 50)

                    HStack(spacing: 16) {
                        HStack(spacing: 16) {
                            ZStack(alignment: .bottomTrailing) {
                                TextField(
                                    "Your bio",
                                    text: viewStore.binding(
                                        get: \.biography,
                                        send: { .setBiography($0) }
                                    ),
                                    axis: .vertical
                                )
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .multilineTextAlignment(.center)
                                .padding(.trailing, 35)
                                .fixedSize(horizontal: false, vertical: true)

                                Text("\(viewStore.biography.count)/\(viewStore.textMaxLength)")
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
                    .padding()

                    Spacer()
                        .frame(height: 50)

                    HStack {
                        ChattyButton(
                            text: "Delete picture",
                            backgroundColor: AppColor.error
                        ) {
                            viewStore.send(.deleteImage)
                        }
                        .disabled(viewStore.account.picture.isEmpty)
                        .opacity(viewStore.account.picture.isEmpty ? 0.8 : 1)

                        ChattyButton(
                            text: "Update profile",
                            isLoading: viewStore.accountState == .loading
                        ) {
                            viewStore.send(.updateImage)
                        }
                        .disabled(!viewStore.didImagePickedOrBiographyChanged)
                        .opacity(!viewStore.didImagePickedOrBiographyChanged ? 0.8 : 1)
                    }
                    .padding()
                    .disabled(viewStore.accountState == .loading)
                }
                .navigationTitle("Edit profile")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: viewStore.accountState) { accountState in
                    if case .loaded = accountState {
                        dismiss()
                    }
                }
                .onDisappear {
                    viewStore.send(.reset)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UniversalHelper.resignFirstResponder()
            }
        }
    }
}
