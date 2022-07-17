//
//  RegisterCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import Foundation

class RegisterCall: Call {
    typealias Response = Account

    let path: String = "register"
    let httpMethod: HTTPMethod = .POST
    let body: Data?

    init(body: Register) {
        do {
            self.body = try JSONEncoder().encode(body)
        } catch {
            self.body = nil

            print(error)
        }
    }
}
