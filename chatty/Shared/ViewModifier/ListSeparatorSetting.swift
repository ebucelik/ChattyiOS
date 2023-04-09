//
//  ListSeparatorSetting.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 09.04.23.
//

import SwiftUI

struct ListSeparatorSetting: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
    }
}
