//
//  UploadPostView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import SwiftHelper
import SwiftUI
import ComposableArchitecture

extension BindingViewStore<UploadPostCore.State> {
    var view: UploadPostView.ViewState {
        UploadPostView.ViewState(
            ownAccountId: self.ownAccountId,
            postState: self.postState,
            pickedImage: self.pickedImage,
            textMaxLength: self.textMaxLength,
            approachesMaxLength: self.approachesMaxLength,
            isImagePicked: self.isImagePicked,
            caption: self.$caption,
            showBanner: self.$showBanner,
            banner: self.banner
        )
    }
}

struct UploadPostView: View {

    struct ViewState: Equatable {
        var ownAccountId: Int?
        var postState: Loadable<Message>
        var pickedImage: UIImage?
        var textMaxLength: Int
        var approachesMaxLength: Bool
        var isImagePicked: Bool
        @BindingViewState var caption: String
        @BindingViewState var showBanner: Bool
        var banner: Banner
    }

    typealias UploadPostViewStore = ViewStore<UploadPostView.ViewState, UploadPostCore.Action.View>
    let store: StoreOf<UploadPostCore>
    let imagePickerController = ImagePickerController(placeholder: "imageUpload")

    var body: some View {
        WithViewStore(store, observe: \.view, send: { .view($0) }) { viewStore in
            NavigationStack {
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

                                    UniversalHelper.resignFirstResponder()
                                }
                                .onAppear {
                                    if case .error = viewStore.postState {
                                        imagePickerController.resetImage()
                                    }
                                }

                        case .loading, .refreshing:
                            LoadingView()
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .contentShape(Rectangle())
                .onTapGesture {
                    UniversalHelper.resignFirstResponder()
                }
                .onDisappear {
                    imagePickerController.resetImage()
                    viewStore.send(.reset)
                }
                .banner(
                    data: viewStore.banner,
                    show: viewStore.$showBanner
                )
            }
        }
    }

    @ViewBuilder
    private func uploadPostBody(_ viewStore: UploadPostViewStore) -> some View {
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
                TextField("Write a caption...", text: viewStore.$caption, axis: .vertical)
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
