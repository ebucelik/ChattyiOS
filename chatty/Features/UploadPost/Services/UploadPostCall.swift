//
//  UploadPostCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation

struct UploadPostCall: Call {
    typealias Response = Message

    var resource: String = "post"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(body: Post) {
        self.body = body
    }
}
