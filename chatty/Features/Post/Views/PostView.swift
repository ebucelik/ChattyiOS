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
                EmptyView()
                    .refreshable {
                        viewStore.send(.fetchPost)
                    }

            case .loading, .refreshing, .none:
                LoadingView()

            case .error:
                ErrorView(text: "An error occured while fetching a post...")
            }
        }
    }
}
