//
//  SearchCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.01.23.
//

import Foundation

struct SearchCall: Call {
    typealias Response = [Account]

    var resource: String = "account/search"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String : Any]) {
        self.parameters = parameters
    }
}
