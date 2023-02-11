//
//  GetAccountsFromPostCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import Foundation

struct GetAccountsFromPostCall: Call {
    typealias Response = [Account]

    var resource: String = "post/postAccounts"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
