//
//  FeedView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI
import ComposableArchitecture

struct FeedView: View {

    let store: Store<FeedCore.State, FeedCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        ForEach(0...50, id: \.self) { _ in
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(
            store: Store(
                initialState: FeedCore.State(),
                reducer: FeedCore()
            )
        )
    }
}
#endif
