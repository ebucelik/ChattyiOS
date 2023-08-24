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
    let onDeleteAccountTap: () -> Void
    let deleteAccount: () -> Void
    let showDeleteAlert: Binding<Bool>

    init(onLogoutTap: @escaping () -> Void,
         onDeleteAccountTap: @escaping () -> Void,
         deleteAccount: @escaping () -> Void,
         showDeleteAlert: Binding<Bool>) {
        self.onLogoutTap = onLogoutTap
        self.onDeleteAccountTap = onDeleteAccountTap
        self.deleteAccount = deleteAccount
        self.showDeleteAlert = showDeleteAlert
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
                    .onTapGesture {
                        onDeleteAccountTap()
                    }
            }
            .padding(24)
            .navigationTitle(Text("More"))
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "Account deletion",
                isPresented: showDeleteAlert,
                actions: {
                    Button(
                        role: .cancel,
                        action: {}
                    ) {
                        Text("Cancel")
                    }

                    Button(
                        role: .destructive,
                        action: {
                            dismiss()
                            deleteAccount()
                        }
                    ) {
                        Text("Delete permanently")
                    }
                },
                message: {
                    Text("Do you really want to delete your account permanently?")
                }
            )
        }
    }
}
