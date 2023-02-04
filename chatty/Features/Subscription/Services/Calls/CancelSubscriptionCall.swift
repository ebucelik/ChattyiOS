//
//  CancelSubscriptionCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation

struct CancelSubscriptionCall: Call {
    typealias Response = Message

    var resource: String = "account/cancelSubscription"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(body: Subscriber) {
        self.body = body
    }
}
