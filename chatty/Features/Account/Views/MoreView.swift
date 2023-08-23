//
//  MoreView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import SwiftUI

struct MoreView: View {

    @Environment(\.dismiss) var dismiss

    let onLogoutTap: () -> Void

    init(onLogoutTap: @escaping () -> Void) {
        self.onLogoutTap = onLogoutTap
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Image(systemSymbol: .infoCircle)
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text("Privacy policy")

                    Spacer()
                }
                .padding()
                .background(AppColor.lightgray)
                .cornerRadius(6)

                HStack {
                    Image(systemSymbol: .rectanglePortraitAndArrowRight)
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text("Sign out")

                    Spacer()
                }
                .padding()
                .background(AppColor.error)
                .cornerRadius(6)
                .onTapGesture {
                    dismiss()
                    onLogoutTap()
                }

                Spacer()

                Text("Delete account")
                    .bold()
                    .foregroundColor(AppColor.error)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(24)
            .navigationTitle(Text("More"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
