//
//  InfoView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 18.01.23.
//

import SwiftUI

struct InfoView: View {
    let info: String
    let action: (() -> Void)?

    init(info: String, action: (() -> Void)? = nil) {
        self.info = info
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(info)
                .font(AppFont.title3.bold())
                .frame(maxWidth: .infinity, alignment: .center)

            if let action = action {
                ChattyButton(text: "Retry", action: action)
            }

            Spacer()
        }
        .padding()
    }
}
