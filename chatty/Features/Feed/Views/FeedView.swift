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
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    GeometryReader { reader in
                        List {
                            feedBody(
                                viewStore,
                                reader: reader
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .listStyle(.plain)
                        .background(Color.white)
                        .refreshable {
                            viewStore.send(.loadPosts)
                        }
                        .onAppear {
                            viewStore.send(.loadPosts)
                        }
                    }
                }
                .onChange(of: viewStore.account) { account in
                    guard account != nil else { return }

                    viewStore.send(.onScroll)
                }
                .navigationTitle("Welcome \(viewStore.username)")
            }
        }
    }

    @ViewBuilder
    private func feedBody(_ viewStore: ViewStoreOf<FeedCore>, reader: GeometryProxy) -> some View {
        if viewStore.posts.isEmpty {
            InfoView(
                text: """
                            There are currently no posts available.
                            Come back later again.
                            """)
            .frame(maxWidth: .infinity)
            .listSeparatorSetting()
        } else {
            ForEachStore(
                store.scope(
                    state: \.postsStates,
                    action: FeedCore.Action.post(id:action:)
                )
            ) { postStore in
                PostView(
                    store: postStore,
                    size: reader.size
                )
                .redacted(reason: viewStore.posts.first == .mock ? .placeholder : .privacy)
                .listSeparatorSetting(
                    edgeInsets: EdgeInsets(
                        top: 16,
                        leading: 0,
                        bottom: 16,
                        trailing: 0
                    )
                )
            }

            if viewStore.postsComplete {
                Text("""
                            You have all shared posts from your friends.
                            Come back later again.
                            """)
                .font(AppFont.caption)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .listSectionSeparator(.hidden)
                .fixedSize(horizontal: false, vertical: true)
                .onAppear {
                    viewStore.send(.onScroll)
                }
                .padding(.vertical, 25)
            } else {
                LoadingView()
                    .frame(maxWidth: .infinity)
                    .listSectionSeparator(.hidden)
                    .onAppear {
                        viewStore.send(.onScroll)
                    }
                    .padding(.vertical, 25)
            }
        }
    }
}
