//
//  ChatSessionCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation

struct ChatSessionCall: Call {
    typealias Response = [ChatSession]

    var resource: String = "chat"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
