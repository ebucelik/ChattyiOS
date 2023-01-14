//
//  RegisterCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import Foundation

class RegisterCall: Call {
    typealias Response = Account

    let resource: String = "account/register"
    let httpMethod: HTTPMethod = .POST
    let body: Codable?

    init(body: Register) {
        self.body = body
    }
}
