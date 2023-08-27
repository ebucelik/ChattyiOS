//
//  CustomUI.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 03.10.22.
//

import SwiftUI
import SwiftHelper
import CachedAsyncImage

public struct ChattyDivider: View {
    public var body: some View {
        Divider()
    }
}

public struct ChattyIcon: View {

    private let width: CGFloat
    private let height: CGFloat

    public init(width: CGFloat = 100, height: CGFloat = 100) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        Image("appicon")
            .resizable(resizingMode: .stretch)
            .frame(width: width, height: height)
            .cornerRadius(width/2)
            .padding()
    }
}

public struct ChattyButton: View {

    private let text: String
    private let isLoading: Bool?
    private let backgroundColor: Color?
    private let action: () -> Void

    public init(text: String = "",
                isLoading: Bool? = nil,
                backgroundColor: Color? = nil,
                action: @escaping () -> Void) {
        self.text = text
        self.isLoading = isLoading
        self.backgroundColor = backgroundColor
        self.action = action
    }

    public var body: some View {
        VStack {
            Button(action: action) {
                if let isLoading = isLoading, isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                } else {
                    Text(text.localize())
                        .font(AppFont.headline)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .disabled(isLoading ?? false)
        }
        .background(backgroundColor == nil ? AppColor.primary : backgroundColor)
        .cornerRadius(6)
        .shadow(radius: 4)
    }
}

public struct ChattyImage: View {
    let picture: String
    let frame: CGSize

    public init(picture: String, frame: CGSize) {
        self.picture = picture
        self.frame = frame
    }

    public var body: some View {
        if picture.isEmpty {
            Image(systemSymbol: .personCircle)
                .renderingMode(.template)
                .resizable()
                .frame(width: frame.width, height: frame.height)
                .foregroundColor(AppColor.gray)
        } else {
            CachedAsyncImage(url: URL(string: picture), urlCache: .imageCache) { profilePicture in
                profilePicture
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemSymbol: .personCircle)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .redacted(reason: .placeholder)
            }
            .frame(width: frame.width, height: frame.height)
            .cornerRadius(frame.width / 2)
        }
    }
}
