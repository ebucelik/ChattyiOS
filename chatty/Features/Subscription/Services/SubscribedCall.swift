//
//  SubscribedCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.01.23.
//

import Foundation

struct SubscribedCall: Call {
    typealias Response = [Account]

    var resource: String = "account/subscribed"
    var parameters: [String : Any]?
    var httpMethod: HTTPMethod = .GET

    init(parameters: [String : Int]) {
        self.parameters = parameters
    }
}
