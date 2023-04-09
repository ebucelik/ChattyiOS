//
//  UploadPostView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import SwiftUI
import ComposableArchitecture

struct UploadPostView: View {

    let store: StoreOf<UploadPostCore>
    let imagePickerController = ImagePickerController(placeholder: "imageUpload")

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack(spacing: 24) {
                    uploadPostBody(viewStore)
                }
                .padding(24)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        switch viewStore.postState {
                        case .loaded:
                            Image(systemSymbol: .checkmarkCircleFill)
                                .foregroundColor(AppColor.success)
                                .onAppear {
                                    imagePickerController.resetImage()
                                    viewStore.send(.reset)
                                }

                        case .none, .error:
                            Text("Upload")
                                .foregroundColor(viewStore.isImagePicked ? AppColor.primary : AppColor.lightgray)
                                .font(viewStore.isImagePicked ? .headline.bold() : .headline)
                                .disabled(!viewStore.isImagePicked)
                                .onTapGesture {
                                    viewStore.send(.uploadPost)
                                }

                        case .loading, .refreshing:
                            LoadingView()
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
                .onDisappear {
                    imagePickerController.resetImage()
                    viewStore.send(.reset)
                }
            }
        }
    }

    @ViewBuilder
    private func uploadPostBody(_ viewStore: ViewStoreOf<UploadPostCore>) -> some View {
        ViewControllerRepresentable(
            viewController: imagePickerController
        )
        .frame(width: 200, height: 200)
        .cornerRadius(12)
        .shadow(radius: viewStore.isImagePicked ? 3 : 0)
        .onAppear {
            imagePickerController.onImagePicked = { pickedImage in
                viewStore.send(.setImage(pickedImage))
            }
        }

        HStack(spacing: 16) {
            Image(systemSymbol: .docTextBelowEcgFill)
                .foregroundColor(AppColor.primary)

            ZStack(alignment: .bottomTrailing) {
                TextField("Write a caption...", text: viewStore.binding(\.$caption), axis: .vertical)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.trailing, 35)

                Text("\(viewStore.caption.count)/\(viewStore.textMaxLength)")
                    .foregroundColor(viewStore.approachesMaxLength ? AppColor.error : AppColor.primary)
                    .font(viewStore.approachesMaxLength ? .caption.bold() : .caption)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(viewStore.caption.isEmpty ? AppColor.lightgray : AppColor.gray, lineWidth: 2)
        )

        Spacer()
    }
}
