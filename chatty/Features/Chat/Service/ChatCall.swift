//
//  ChatCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 02.05.23.
//

import Foundation

struct ChatCall: Call {
    typealias Response = [Chat]

    var resource: String = "chat/messages"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
