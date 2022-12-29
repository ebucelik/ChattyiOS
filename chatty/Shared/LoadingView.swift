//
//  LoadingView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 29.12.22.
//

import SwiftUI

struct LoadingView: View {
    let tint: Color
    let fullScreen: Bool

    init(_ tint: Color = AppColor.button, fullScreen: Bool = false) {
        self.tint = tint
        self.fullScreen = fullScreen
    }

    var body: some View {
        if fullScreen {
            VStack {
                Spacer()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(tint)

                Spacer()
            }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .tint(tint)
        }
    }
}
