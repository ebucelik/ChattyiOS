//
//  Account.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

struct Account: Equatable, Codable {
    let username: String
    let email: String

    init(username: String, email: String) {
        self.username = username
        self.email = email
    }
}
