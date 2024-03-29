//
//  SubscriptionInfoCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation

struct SubscriptionInfoCall: Call {
    typealias Response = SubscriptionInfo

    var resource: String = "account/subscriptionInfo"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(body: Subscriber) {
        self.body = body
    }
}
