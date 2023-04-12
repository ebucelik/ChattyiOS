//
//  ListSeparatorSetting.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 09.04.23.
//

import SwiftUI

struct ListSeparatorSetting: ViewModifier {

    let edgeInsets: EdgeInsets?

    init(edgeInsets: EdgeInsets? = nil) {
        self.edgeInsets = edgeInsets
    }

    func body(content: Content) -> some View {
        content
            .listRowInsets(edgeInsets)
            .listRowBackground(Color.clear)
    }
}
