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

    static func removeUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
