//
//  LikePostCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import Foundation

struct LikePostCall: Call {
    typealias Response = Message

    var resource: String = "post/like"
    var httpMethod: HTTPMethod = .POST
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
