//
//  Subscriber.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation

struct Subscriber: Codable, Equatable {
    let userId: Int
    let subscribedUserId: Int
    let accepted: Bool

    init(userId: Int, subscribedUserId: Int, accepted: Bool) {
        self.userId = userId
        self.subscribedUserId = subscribedUserId
        self.accepted = accepted
    }
}
