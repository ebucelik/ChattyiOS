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
    let body: Data?

    init(body: Login? = nil) {
        do {
            self.body = try JSONEncoder().encode(body)
        } catch {
            self.body = nil

            print(error)
        }
    }
}
