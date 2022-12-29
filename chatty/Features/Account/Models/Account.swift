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

extension Account {
    static let identifier = "account"

    static func removeFromUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    static func addToUserDefaults(_ account: Self) {
        do {
            let data = try JSONEncoder().encode(account)
            UserDefaults.standard.set(data, forKey: Account.identifier)
            UserDefaults.standard.synchronize()
        } catch {
            print("ERROR: \(error)")
        }
    }

    static func getFromUserDefaults() -> Account? {
        if let data = UserDefaults.standard.data(forKey: Account.identifier) {
            do {
                return try JSONDecoder().decode(self, from: data)
            } catch {
                print("ERROR: \(error)")
            }
        }

        return nil
    }
}
