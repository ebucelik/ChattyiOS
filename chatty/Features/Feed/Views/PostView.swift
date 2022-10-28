//
//  PostView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 28.10.22.
//

import SwiftUI

struct PostView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person")
                .resizable()
                .frame(width: 200, height: 200)

            HStack(spacing: 8) {
                Text("120")
                    .font(.system(size: 23))

                Image(systemName: "heart")
                    .resizable()
                    .frame(width: 22, height: 22)

                Spacer()
            }
        }
        .padding(.all, 16)
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
