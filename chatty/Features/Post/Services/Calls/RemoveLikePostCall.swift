//
//  RemoveLikePostCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import Foundation

struct RemoveLikePostCall: Call {
    typealias Response = Message

    var resource: String = "post/removeLike"
    var httpMethod: HTTPMethod = .POST
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
