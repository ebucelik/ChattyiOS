//
//  LoginCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

class LoginCall: Call {
    typealias Response = Account

    let resource: String = "auth/login"
    let httpMethod: HTTPMethod = .POST
    let body: Codable?

    init(body: Login) {
        self.body = body
    }
}
