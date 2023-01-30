//
//  ErrorView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 30.01.23.
//

import SwiftUI

struct ErrorView: View {

    let text: String
    let action: (() -> Void)?

    init(text: String = "", action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
    }

    var body: some View {
        BaseInfoErrorView(text: text, context: .error, action: action)
    }
}
