//
//  FeedPostsCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.04.23.
//

import Foundation

class FeedPostsCall: Call {
    typealias Response = [Post]

    var resource: String = "post/posts"
    var httpMethod: HTTPMethod = .GET
    var parameters: [String : Any]?

    init(parameters: [String : Int]) {
        self.parameters = parameters
    }
}
