//
//  Subscriber.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation

struct Subscriber: Codable, Equatable {
    let userId: Int
    let followerId: Int
    let accepted: Bool

    init(userId: Int, followerId: Int, accepted: Bool) {
        self.userId = userId
        self.followerId = followerId
        self.accepted = accepted
    }
}
