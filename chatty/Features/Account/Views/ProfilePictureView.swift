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

    let imagePickerController = ImagePickerController(placeholder: "person.crop.circle.fill")
    let store: StoreOf<ProfilePictureCore>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
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

                Spacer()
                    .frame(height: 50)

                VStack {
                    ChattyButton(
                        text: "Update profile picture",
                        isLoading: viewStore.accountState == .loading
                    ) {
                        viewStore.send(.updateImage)
                    }

                    ChattyButton(
                        text: "Delete profile picture",
                        isLoading: viewStore.accountState == .loading,
                        backgroundColor: AppColor.error
                    ) {
                        viewStore.send(.deleteImage)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile Picture")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewStore.accountState) { accountState in
                if case .loaded = accountState {
                    dismiss()
                }
            }
        }
    }
}
