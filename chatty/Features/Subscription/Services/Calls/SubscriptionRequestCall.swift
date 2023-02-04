//
//  SubscriptionRequestCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.01.23.
//

import Foundation

struct SubscriptionRequestCall: Call {
    typealias Response = [Account]

    var resource: String = "account/subscriptionRequests"
    var parameters: [String : Any]?
    var httpMethod: HTTPMethod = .GET

    init(parameters: [String : Int]) {
        self.parameters = parameters
    }
}
