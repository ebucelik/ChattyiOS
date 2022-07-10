//
//  LoginCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

class LoginCall: Call {
    typealias Response = Account

    let path: String = "login"
    let httpMethod: HTTPMethod = .POST
    let body: Login?

    init(body: Login? = nil) {
        self.body = body
    }
}
