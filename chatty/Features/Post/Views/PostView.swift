//
//  PostView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 28.10.22.
//

import SwiftUI
import ComposableArchitecture

struct PostView: View {

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

            case .loading, .refreshing, .none:
                LoadingView()

            case .error:
                ErrorView(text: "An error occured while fetching a post...")
            }
        }
    }
}
