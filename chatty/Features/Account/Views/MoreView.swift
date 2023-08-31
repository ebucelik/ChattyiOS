//
//  MoreView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import SwiftUI

struct MoreView: View {

    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var inAppStore: InAppStore

    let isOtherAccount: Bool
    let onLogoutTap: () -> Void
    let onDeleteAccountTap: () -> Void
    let deleteAccount: () -> Void
    let showDeleteAlert: Binding<Bool>
    let onBuyMeACoffeTap: () -> Void
    let onPrivacyPolicyTap: () -> Void
    let onBlockAccountTap: () -> Void

    init(isOtherAccount: Bool,
         onLogoutTap: @escaping () -> Void,
         onDeleteAccountTap: @escaping () -> Void,
         deleteAccount: @escaping () -> Void,
         showDeleteAlert: Binding<Bool>,
         onBuyMeACoffeTap: @escaping () -> Void,
         onPrivacyPolicyTap: @escaping () -> Void,
         onBlockAccountTap: @escaping () -> Void) {
        self.isOtherAccount = isOtherAccount
        self.onLogoutTap = onLogoutTap
        self.onDeleteAccountTap = onDeleteAccountTap
        self.deleteAccount = deleteAccount
        self.showDeleteAlert = showDeleteAlert
        self.onBuyMeACoffeTap = onBuyMeACoffeTap
        self.onPrivacyPolicyTap = onPrivacyPolicyTap
        self.onBlockAccountTap = onBlockAccountTap
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if isOtherAccount {
                    HStack {
                        Image(systemSymbol: .personCropCircleFill)
                            .resizable()
                            .frame(width: 20, height: 20)

                        Text("Block profile")

                        Spacer()
                    }
                    .padding()
                    .background(AppColor.error)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .onTapGesture {
                        dismiss()

                        onBlockAccountTap()
                    }

                    Spacer()
                } else {
                    HStack {
                        Image("bmc-logo-no-background")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)

                        Text("Buy me a coffee")

                        Spacer()
                    }
                    .padding()
                    .background(AppColor.lightgray)
                    .cornerRadius(6)
                    .onTapGesture {
                        dismiss()

                        onBuyMeACoffeTap()
                    }

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
                    .onTapGesture {
                        dismiss()

                        onPrivacyPolicyTap()
                    }

                    HStack {
                        Image(systemSymbol: .rectanglePortraitAndArrowRight)
                            .resizable()
                            .frame(width: 20, height: 20)

                        Text("Sign out")

                        Spacer()
                    }
                    .padding()
                    .background(AppColor.error)
                    .foregroundColor(.white)
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
