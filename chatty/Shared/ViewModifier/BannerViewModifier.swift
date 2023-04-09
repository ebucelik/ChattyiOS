//
//  BannerViewModifier.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 09.04.23.
//

import SwiftUI

struct BannerViewModifier: ViewModifier {

    var banner: Banner
    
    @Binding
    var show: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if show {
                VStack {
                    Spacer()

                    HStack {
                        VStack(alignment: .leading) {
                            Text(banner.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(AppFont.headline)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                        }

                        Spacer()

                        banner.type.image
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(banner.type.backgroundColor)
                    .cornerRadius(6)
                    .padding()
                }
            }
        }
    }
}
