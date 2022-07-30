//
//  Register.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

struct Register: Equatable, Codable {
    var username: String
    var email: String
    var password: String

    init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }
}

extension Register {
    static var empty: Register {
        Register(
            username: "",
            email: "",
            password: ""
        )
    }
}
