//
//  DeclineSubscriptionCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation

struct DeclineSubscriptionCall: Call {
    typealias Response = Message

    var resource: String = "account/declineSubscription"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(body: Subscriber) {
        self.body = body
    }
}
