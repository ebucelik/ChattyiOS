//
//  ChattyNavigationView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 06.02.23.
//

import SwiftUI

struct ChattyNavigationView: ViewModifier {
    let isOtherAccount: Bool

    func body(content: Content) -> some View {
        if isOtherAccount {
            content
        } else {
            NavigationStack {
                content
            }
        }
    }
}
