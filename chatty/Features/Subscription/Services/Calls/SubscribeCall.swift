//
//  SubscribeCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation

struct SubscribeCall: Call {
    typealias Response = SubscriptionInfo

    var resource: String = "account/subscribe"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(body: Subscriber) {
        self.body = body
    }
}
