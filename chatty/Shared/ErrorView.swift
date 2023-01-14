//
//  ErrorView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 29.12.22.
//

import SwiftUI

struct ErrorView: View {
    let error: String
    let action: (() -> Void)?

    init(error: String = "Oups, something bad happened :(", action: (() -> Void)? = nil) {
        self.error = error
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(error)
                .font(AppFont.title2.bold())

            if let action = action {
                ChattyButton(text: "Retry", action: action)
            }

            Spacer()
        }
    }
}
