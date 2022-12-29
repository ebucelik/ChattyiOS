//
//  AccountView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI
import ComposableArchitecture

struct AccountView: View {

    let store: StoreOf<AccountCore>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                switch viewStore.accountState {
                case .loading, .refreshing, .none:
                    LoadingView()

                case let .loaded(account):
                    accountBody(with: account, viewStore)

                case let .error(error):
                    ErrorView(
                        error: error.localizedDescription,
                        action: { viewStore.send(.fetchAccount) }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func accountBody(with account: Account, _ viewStore: ViewStoreOf<AccountCore>) -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                Image(systemName: "person.circle")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 125, height: 125)
                    .foregroundColor(AppColor.button)

                ChattyDivider()

                HStack(spacing: 16) {
                    Text("287")
                        .font(.headline.monospaced())

                    ChattyDivider()

                    Text("115")
                        .font(.headline.monospaced())

                    ChattyDivider()

                    Text("10")
                        .font(.headline.monospaced())
                }

                ChattyDivider()

                ChattyButton(text: "I want to know", action: {})
                    .padding(.horizontal)

                ChattyDivider()
            }
            .padding()
            .padding(.top, 24)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ChattyIcon(width: 30, height: 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(
            store: Store(
                initialState: AccountCore.State(),
                reducer: AccountCore()
            )
        )
    }
}
#endif
