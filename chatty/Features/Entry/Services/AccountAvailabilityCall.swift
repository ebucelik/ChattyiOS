//
//  AccountAvailabilityCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 30.07.22.
//

import Foundation

class AccountAvailabilityCall: Call {
    typealias Response = Bool

    var resource: String = "auth/check"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String: Any]?) {
        self.parameters = parameters
    }
}
