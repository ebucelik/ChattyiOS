//
//  FeedView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.07.22.
//

import SwiftUI

struct FeedView: View {

    @State
    var showEntryView = true

    var body: some View {
        VStack {
            Text("Hi")
            Text("Ebu")
            Text("BSc")
        }
        .onAppear {
            if UserDefaults.standard.data(forKey: "account") != nil {
                showEntryView = false
            }
        }
        .fullScreenCover(isPresented: $showEntryView) {
            LoginView(
                store: .init(
                    initialState: LoginCore.State(),
                    reducer: LoginCore.reducer,
                    environment: LoginCore.Environment(
                        service: LoginService(),
                        mainDispatcher: .main,
                        completion: { showHomepage in
                            if showHomepage {
                                self.showEntryView = false
                            }
                        }
                    )
                )
            )
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
#endif
