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
    let timestamp: Double
    let likedByYou: Bool?

    init(id: Int,
         userId: Int,
         imageLink: String,
         likesCount: Int,
         caption: String,
         timestamp: Double,
         likedByYou: Bool?) {
        self.id = id
        self.userId = userId
        self.imageLink = imageLink
        self.likesCount = likesCount
        self.caption = caption
        self.timestamp = timestamp
        self.likedByYou = likedByYou
    }
}

extension Post {
    static var mock: Post {
        Post(
            id: 0,
            userId: 0,
            imageLink: "https://www.google.at/url?sa=i&url=https%3A%2F%2Fwww.veryicon.com%2Ficons%2Finternet--web%2F55-common-web-icons%2Fperson-4.html&psig=AOvVaw3VIapzYUQB0vUzOr9yR5jy&ust=1680995440431000&source=images&cd=vfe&ved=0CBEQjRxqFwoTCOiQzZLymP4CFQAAAAAdAAAAABAE",
            likesCount: 10,
            caption: "",
            timestamp: 0,
            likedByYou: false
        )
    }
}
