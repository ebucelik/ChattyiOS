//
//  AccountCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 15.01.23.
//

import Foundation

struct AccountCall: Call {
    typealias Response = Account

    var resource: String = "account"
    var parameters: [String : Any]?
    var httpMethod: HTTPMethod = .GET

    init(parameters: [String : Int]?) {
        self.parameters = parameters
    }
}
