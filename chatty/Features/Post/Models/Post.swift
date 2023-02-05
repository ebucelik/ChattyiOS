//
//  Post.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation

struct Post: Codable, Identifiable, Equatable {
    let id: Int
    let userId: Int
    let imageLink: String
    let likesCount: Int
    let caption: String
    let timestamp: Int?

    init(id: Int,
         userId: Int,
         imageLink: String,
         likesCount: Int,
         caption: String,
         timestamp: Int? = nil) {
        self.id = id
        self.userId = userId
        self.imageLink = imageLink
        self.likesCount = likesCount
        self.caption = caption
        self.timestamp = timestamp
    }
}
