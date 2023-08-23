//
//  PostView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 28.10.22.
//

import SwiftHelper
import SwiftUI
import ComposableArchitecture
import CachedAsyncImage

extension BindingViewStore<PostCore.State> {
    var view: PostView.ViewState {
        PostView.ViewState(
            otherAccountId: self.otherAccountId,
            ownAccountId: self.ownAccountId,
            postState: self.postState,
            deletePostState: self.deletePostState,
            reportPostState: self.reportPostState,
            postDate: self.postDate,
            postTime: self.postTime,
            showAlert: self.$showAlert,
            showDeleteAlert: self.$showDeleteAlert,
            showReportAlert: self.$showReportAlert,
            showReportView: self.$showReportView,
            scale: self.$scale,
            postLiked: self.postLiked,
            isFeedView: self.isFeedView,
            isOtherAccount: self.isOtherAccount
        )
    }
}

struct PostView: View {
    struct ViewState: Equatable {
        var otherAccountId: Int?
        var ownAccountId: Int?
        var postState: Loadable<Post>
        var deletePostState: Loadable<Message>
        var reportPostState: Loadable<Report>
        var postDate: String
        var postTime: String
        @BindingViewState var showAlert: Bool
        @BindingViewState var showDeleteAlert: Bool
        @BindingViewState var showReportAlert: Bool
        @BindingViewState var showReportView: Bool
        @BindingViewState var scale: Double
        var postLiked: Bool
        var isFeedView: Bool
        var isOtherAccount: Bool
    }

    @Environment(\.dismiss) var dismiss

    typealias PostViewStore = ViewStore<PostView.ViewState, PostCore.Action.View>
    let store: StoreOf<PostCore>
    let size: CGSize

    var body: some View {
        WithViewStore(store, observe: \.view, send: { .view($0) }) { viewStore in
            switch viewStore.postState {
            case let .loaded(post):
                VStack(spacing: 16) {
                    HStack {
                        if viewStore.isFeedView {
                            NavigationLink {
                                IfLetStore(
                                    store.scope(
                                        state: \.account,
                                        action: PostCore.Action.account
                                    )
                                ) { accountStore in
                                    AccountView(store: accountStore)
                                }
                            } label: {
                                headerPostBody(post)
                            }
                        } else {
                            headerPostBody(post)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)

                    CachedAsyncImage(url: URL(string: post.imageLink), urlCache: .imageCache) { image in
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
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25)
                                .foregroundColor(viewStore.postLiked ? AppColor.red : .black)
                                .onTapGesture {
                                    if viewStore.postLiked {
                                        viewStore.send(.removeLikeFromPost)
                                    } else {
                                        viewStore.send(.setScale(1.3))
                                        viewStore.send(.likePost)
                                    }
                                }
                                .scaleEffect(viewStore.scale)
                                .animation(.easeOut, value: viewStore.scale)
                                .onAppear {
                                    viewStore.send(.setScale(1.0))
                                }

                            Text("\(post.likesCount)")
                                .frame(alignment: .center)
                                .font(AppFont.headline)

                            Spacer()

                            if viewStore.isFeedView {
                                reportPostBody(viewStore)
                            } else {
                                deletePostBody(viewStore)
                                    .disabled(viewStore.isOtherAccount)
                                    .opacity(viewStore.isOtherAccount ? 0 : 1)
                                    .alert(isPresented: viewStore.$showDeleteAlert) {
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

                        HStack {
                            VStack {
                                HStack {
                                    Image(systemSymbol: .calendar)
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(AppColor.gray)

                                    Text(viewStore.postDate)
                                        .font(AppFont.footnote)
                                        .foregroundColor(AppColor.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                HStack {
                                    Image(systemSymbol: .clock)
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(AppColor.gray)

                                    Text(viewStore.postTime)
                                        .font(AppFont.footnote)
                                        .foregroundColor(AppColor.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .alert(
                    "Post deletion",
                    isPresented: viewStore.$showAlert,
                    actions: {},
                    message: {
                        Text("An error occured while trying to delete your post...")
                    }
                )
                .alert(
                    "Report",
                    isPresented: viewStore.$showReportAlert,
                    actions: {
                        Button("Ok") {
                            viewStore.send(.loadPosts)
                        }
                    },
                    message: {
                        Text("Your report was successfully delivered. We are sorry for this experience.")
                    }
                )
                .onTapGesture(count: 2) {
                    viewStore.send(.setScale(1.3))
                    viewStore.send(.likePost)
                }
                .sheet(isPresented: viewStore.$showReportView) {
                    NavigationStack {
                        VStack {
                            VStack {
                                Text("Why are you reporting this post?")
                                    .font(AppFont.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Your report is anonymous.")
                                    .font(AppFont.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()

                            List(ReportReason.allCases.filter { $0 != .none }, id: \.hashValue) { reportReason in
                                Text(reportReason.rawValue)
                                    .onTapGesture {
                                        viewStore.send(.setReportReason(reportReason))
                                        viewStore.send(.showReportView)
                                        viewStore.send(.reportPost)
                                    }
                            }
                            .frame(maxWidth: .infinity)
                            .listStyle(.plain)
                            .background(Color.white)
                        }
                        .navigationTitle("Report reasons")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }

            case .loading, .refreshing, .none:
                LoadingView()

            case .error:
                ErrorView(text: "An error occured while fetching a post...")
            }
        }
    }

    @ViewBuilder
    private func headerPostBody(_ post: Post) -> some View {
        CachedAsyncImage(url: URL(string: post.account.picture), urlCache: .imageCache) { image in
            image
                .resizable()
                .frame(width: 35, height: 35)
        } placeholder: {
            AppColor.lightgray
        }
        .frame(width: 35, height: 35)
        .cornerRadius(17.5)

        Text("\(post.account.username)")
            .frame(alignment: .center)
            .font(AppFont.title3)
    }

    @ViewBuilder
    private func deletePostBody(_ viewStore: PostViewStore) -> some View {
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
    private func reportPostBody(_ viewStore: PostViewStore) -> some View {
        switch viewStore.reportPostState {
        case .loaded:
            reportImage()
                .onAppear {
                    dismiss()
                }

        case .none:
            reportImage()
                .onTapGesture {
                    viewStore.send(.showReportView)
                }

        case .loading, .refreshing:
            LoadingView()

        case .error:
            reportImage()
                .onTapGesture {
                    viewStore.send(.showReportView)
                }
        }
    }

    @ViewBuilder
    private func trashImage() -> some View {
        Image(systemSymbol: .trash)
            .resizable()
            .foregroundColor(AppColor.error)
            .aspectRatio(contentMode: .fit)
            .frame(width: 22.5)
    }

    @ViewBuilder
    private func reportImage() -> some View {
        Image(systemSymbol: .exclamationmarkBubble)
            .resizable()
            .foregroundColor(AppColor.gray)
            .aspectRatio(contentMode: .fit)
            .frame(width: 25)
    }
}
