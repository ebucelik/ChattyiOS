//
//  CustomUI.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 03.10.22.
//

import SwiftUI
import SwiftHelper

public struct ChattyDivider: View {
    public var body: some View {
        Divider()
            .padding(.horizontal)
    }
}

public struct ChattyIcon: View {

    private let width: CGFloat?
    private let height: CGFloat?

    public init(width: CGFloat? = 100, height: CGFloat? = 100) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        Image(systemName: "message.circle")
            .resizable(resizingMode: .stretch)
            .frame(width: width, height: height)
            .padding()
            .foregroundColor(AppColor.primary)
    }
}

public struct ChattyButton: View {

    private let text: String
    private let isLoading: Bool?
    private let action: () -> Void

    public init(text: String, isLoading: Bool? = nil, action: @escaping () -> Void) {
        self.text = text
        self.isLoading = isLoading
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
                    Text(text)
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
        .background(AppColor.primary)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}
