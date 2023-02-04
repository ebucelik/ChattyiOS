//
//  Post.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let imageLink: String
    let likesCount: Int
    let caption: String

    init(id: Int,
         userId: Int,
         imageLink: String,
         likesCount: Int,
         caption: String) {
        self.id = id
        self.userId = userId
        self.imageLink = imageLink
        self.likesCount = likesCount
        self.caption = caption
    }
}
