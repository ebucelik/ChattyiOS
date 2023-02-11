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
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text("Privacy policy")

                    Spacer()
                }
                .padding()
                .background(AppColor.lightgray)
                .cornerRadius(6)

                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text("Signout")

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
