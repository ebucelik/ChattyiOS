//
//  RegisterView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import SwiftUI

import ComposableArchitecture
import SwiftHelper

struct RegisterView: View {

    typealias RegisterViewStore = ViewStore<RegisterCore.State, RegisterCore.Action>
    let store: Store<RegisterCore.State, RegisterCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(get: \.tabSelection, send: .nextTab(nil))) {
                provideUsername(viewStore)
                    .tag(0)
                Text("Second")
                    .tag(1)
                Button(
                    action: {
                        viewStore.send(.showLoginView)
                    }, label: {
                        Text("LoginView")
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .onAppear {
                UIScrollView.appearance().isScrollEnabled = false
            }
        }
    }

    @ViewBuilder
    func provideUsername(_ viewStore: RegisterViewStore) -> some View {
        VStack(spacing: 50) {
            HStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .foregroundColor(Colors.gray)
                    TextField("Username", text: viewStore.binding(\.$register.username))
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .onChange(of: viewStore.register.username) { _ in
                            viewStore.send(.checkUsername)
                        }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Colors.gray, lineWidth: 2)
                )


                switch viewStore.accountAvailabilityState {
                case .loading, .refreshing:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 30, height: 30, alignment: .center)

                case .none:
                    EmptyView()

                case .loaded:
                    if viewStore.isAccountAvailable {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Colors.success)
                    } else {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Colors.error)
                    }

                case .error:
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Colors.error)
                }
            }
            .padding()

            if case .loaded = viewStore.accountAvailabilityState, viewStore.isAccountAvailable {
                Button(
                    action: {
                        viewStore.send(.nextTab(viewStore.tabSelection + 1))
                    }, label: {
                        Text("Wonderful!\nLet's go to the next slide")
                            .font(.title)
                            .bold()
                            .italic()
                            .foregroundColor(Colors.button)
                            .frame(alignment: .center)
                            .textCase(.uppercase)
                    }
                )
            }
        }
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(
            store: .init(
                initialState: RegisterCore.State(),
                reducer: RegisterCore.reducer,
                environment: RegisterCore.Environment(
                    service: RegisterService(),
                    accountAvailabilityService: AccountAvailabilityService(),
                    mainScheduler: .main
                )
            )
        )
    }
}
#endif
