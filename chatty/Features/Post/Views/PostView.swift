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
    let size: CGSize

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.postState {
            case let .loaded(post):
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: post.imageLink)) { image in
                        image
                            .resizable()
                            .frame(width: size.width, height: size.width)
                    } placeholder: {
                        AppColor.lightgray
                    }
                    .frame(width: size.width, height: size.width)

                    VStack(spacing: 16) {
                        HStack(alignment: .center) {
                            Image(systemSymbol: viewStore.postLiked ? .heartFill : .heart)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(viewStore.postLiked ? AppColor.red : .black)
                                .onTapGesture {
                                    if viewStore.postLiked {
                                        viewStore.send(.removeLikeFromPost)
                                    } else {
                                        viewStore.send(.likePost)
                                    }
                                }

                            Text("\(post.likesCount)")
                                .frame(alignment: .center)
                                .font(AppFont.headline)

                            Spacer()

                            if !viewStore.isFeedView {
                                deletePostBody(viewStore)
                                    .disabled(viewStore.isOtherAccount)
                                    .opacity(viewStore.isOtherAccount ? 0 : 1)
                                    .alert(isPresented: viewStore.binding(\.$showDeleteAlert)) {
                                        Alert(
                                            title: Text("Post deletion"),
                                            message: Text("Are you sure you want to delete your post?"),
                                            primaryButton: .destructive(Text("Delete")) {
                                                viewStore.send(.deletePost)
                                            },
                                            secondaryButton: .cancel()
                                        )
                                    }
                            }
                        }

                        if !post.caption.isEmpty {
                            Text(post.caption)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Text(viewStore.postDate)
                            .font(AppFont.footnote)
                            .foregroundColor(AppColor.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                }
                .alert(
                    "Post deletion",
                    isPresented: viewStore.binding(\.$showAlert),
                    actions: {},
                    message: {
                        Text("An error occured while trying to delete your post...")
                    }
                )
                .onTapGesture(count: 2) {
                    viewStore.send(.likePost)
                }

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
                    viewStore.send(.showDeleteAlert)
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
        Image(systemSymbol: .trash)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(AppColor.error)
            .frame(width: 22.5, height: 25)
    }
}
