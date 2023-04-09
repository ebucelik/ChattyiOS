//
//  Banner.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 09.04.23.
//

import SwiftUI

enum BannerType {
    case success
    case error
    case info

    var backgroundColor: Color {
        switch self {
        case .success:
            return AppColor.success
        case .error:
            return AppColor.error
        case .info:
            return AppColor.gray
        }
    }

    var image: Image {
        switch self {
        case .success:
            return Image(systemSymbol: .checkmarkCircleFill)
        case .error:
            return Image(systemSymbol: .xmarkCircleFill)
        case .info:
            return Image(systemSymbol: .infoCircleFill)
        }
    }
}

struct Banner: Equatable {
    let title: String
    let type: BannerType
}
