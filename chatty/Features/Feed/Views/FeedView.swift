//
//  FeedView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI
import ComposableArchitecture

struct FeedView: View {

    let store: StoreOf<FeedCore>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                GeometryReader { reader in
                    List {
                        if viewStore.posts.isEmpty {
                            InfoView(
                                text: """
                                        There are currently no posts available.
                                        Come back later again 🫡
                                        """)
                            .frame(maxWidth: .infinity)
                            .modifier(ListSeparatorSetting())
                        } else {
                            ForEach(viewStore.posts) { post in
                                PostView(
                                    store: Store(
                                        initialState: PostCore.State(
                                            otherAccountId: nil,
                                            ownAccountId: viewStore.ownAccountId,
                                            postState: .loaded(post),
                                            isFeedView: true
                                        ),
                                        reducer: PostCore()
                                    ),
                                    size: reader.size
                                )
                                .redacted(reason: viewStore.posts.first == .mock ? .placeholder : .privacy)
                            }
                            .modifier(ListSeparatorSetting())

                            if viewStore.postsComplete {
                                Text("""
                                        You have all shared posts from your friends 😊
                                        Come back later again.
                                        """)
                                    .font(AppFont.caption)
                                    .frame(maxWidth: .infinity)
                                    .modifier(ListSeparatorSetting())
                                    .onAppear {
                                        viewStore.send(.onScroll)
                                    }
                                    .padding(.vertical, 25)
                                    .padding()
                            } else {
                                LoadingView()
                                    .frame(maxWidth: .infinity)
                                    .modifier(ListSeparatorSetting())
                                    .onAppear {
                                        viewStore.send(.onScroll)
                                    }
                                    .padding(.vertical, 25)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listStyle(.grouped)
                    .refreshable {
                        viewStore.send(.loadPosts)
                    }
                    .onAppear {
                        viewStore.send(.loadPosts)
                    }
                }
            }
            .onChange(of: viewStore.ownAccountId) { ownAccountId in
                guard ownAccountId != nil else { return }

                viewStore.send(.onScroll)
            }
        }
    }
}
