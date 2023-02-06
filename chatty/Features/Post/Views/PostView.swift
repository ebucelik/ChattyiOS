//
//  PostView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 28.10.22.
//

import SwiftUI
import ComposableArchitecture

struct PostView: View {

    @Environment(\.dismiss) var dismiss

    let store: StoreOf<PostCore>

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.postState {
            case let .loaded(post):
                GeometryReader { reader in
                    ScrollView {
                        VStack(spacing: 16) {
                            AsyncImage(url: URL(string: post.imageLink)) { image in
                                image
                                    .resizable()
                                    .frame(width: reader.size.width, height: reader.size.width)
                            } placeholder: {
                                AppColor.gray
                            }
                            .frame(width: reader.size.width, height: reader.size.width)

                            VStack(spacing: 16) {
                                HStack(alignment: .center) {
                                    Image(systemName: "heart")
                                        .resizable()
                                        .frame(width: 25, height: 25)

                                    Text("\(post.likesCount)")
                                        .frame(alignment: .center)
                                        .font(AppFont.headline)

                                    Spacer()

                                    deletePostBody(viewStore)
                                }

                                Text(post.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 24)
                    }
                    .refreshable {
                        viewStore.send(.fetchPost)
                    }
                }
                .alert(
                    "Post deletion",
                    isPresented: viewStore.binding(\.$showAlert),
                    actions: {},
                    message: {
                        Text("An error occured while trying to delete your post...")
                    }
                )

            case .loading, .refreshing, .none:
                LoadingView()

            case .error:
                ErrorView(text: "An error occured while fetching a post...")
            }
        }
    }

    @ViewBuilder
    private func deletePostBody(_ viewStore: ViewStoreOf<PostCore>) -> some View {
        switch viewStore.deletePostState {
        case .loaded:
            trashImage()
                .onAppear {
                    dismiss()
                }

        case .none:
            trashImage()
                .onTapGesture {
                    viewStore.send(.deletePost)
                }

        case .loading, .refreshing:
            LoadingView()

        case .error:
            trashImage()
                .onTapGesture {
                    viewStore.send(.deletePost)
                }
                .onAppear {
                    viewStore.send(.showAlert)
                }
        }
    }

    @ViewBuilder
    private func trashImage() -> some View {
        Image(systemName: "trash")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(AppColor.error)
            .frame(width: 22.5, height: 25)
    }
}
