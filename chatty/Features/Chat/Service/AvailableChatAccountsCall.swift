//
//  AvailableChatAccountsCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation

struct AvailableChatAccountsCall: Call {
    typealias Response = [Account]

    var resource: String = "account/availableChatAccounts"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
