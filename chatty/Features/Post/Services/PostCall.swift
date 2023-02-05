//
//  PostCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 05.02.23.
//

import Foundation

struct PostCall: Call {
    typealias Response = Post

    var resource: String = "post/post"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String: Int]) {
        self.parameters = parameters
    }
}
