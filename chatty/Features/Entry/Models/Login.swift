//
//  Login.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

struct Login: Equatable, Codable {
    var email: String
    var password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

extension Login {
    static var empty: Login {
        Login(
            email: "",
            password: ""
        )
    }
}
