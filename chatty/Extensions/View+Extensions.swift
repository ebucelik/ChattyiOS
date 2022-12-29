//
//  View+Extensions.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 26.12.22.
//

import SwiftHelper
import SwiftUI

extension View {
    @ViewBuilder
    func availabilityCheck(for loadable: Loadable<Bool>) -> some View {
        switch loadable {
        case .loading, .refreshing:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(width: 20, height: 20, alignment: .center)

        case .error:
            Image(systemName: "x.circle.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(AppColor.error)

        case let .loaded(available):
            if available {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(AppColor.success)
            } else {
                Image(systemName: "x.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(AppColor.error)
            }

        case .none:
            EmptyView()
        }
    }
}
