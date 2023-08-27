//
//  InfoView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 18.01.23.
//

import SwiftUI

struct InfoView: View {
    let text: String
    let action: (() -> Void)?

    init(text: String, action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
    }

    var body: some View {
        BaseInfoErrorView(text: text.localize(), context: .info, action: action)
    }
}
