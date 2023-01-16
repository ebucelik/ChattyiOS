//
//  AcceptSubscriptionCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation

struct AcceptSubscriptionCall: Call {
    typealias Response = Message

    var resource: String = "account/acceptSubscription"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(body: Subscriber) {
        self.body = body
    }
}
