//
//  BaseInfoErrorView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 30.01.23.
//

import SwiftUI

struct BaseInfoErrorView: View {

    enum Context: String {
        case info
        case error
    }

    let text: String
    let context: BaseInfoErrorView.Context
    let action: (() -> Void)?

    init(text: String = "Oups, something bad happened...", context: BaseInfoErrorView.Context, action: (() -> Void)? = nil) {
        self.text = text
        self.context = context
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(context.rawValue)
                .resizable()
                .frame(width: 75, height: 75)

            Text(text)
                .font(AppFont.title3.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)

            if let action = action {
                ChattyButton(text: "Retry", action: action)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }
}
