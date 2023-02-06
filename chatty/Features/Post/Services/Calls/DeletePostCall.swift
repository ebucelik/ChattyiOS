//
//  DeletePostCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 06.02.23.
//

import Foundation

struct DeletePostCall: Call {
    typealias Response = Message

    var resource: String = "post/delete"
    var httpMethod: HTTPMethod = .POST
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
