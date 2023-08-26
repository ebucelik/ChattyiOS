//
//  Account.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

public struct Account: Equatable, Codable, Hashable {
    let id: Int
    let username: String
    let email: String
    var picture: String
    let subscriberCount: Int
    let subscribedCount: Int
    let postCount: Int
    var biography: String

    init(id: Int,
         username: String,
         email: String,
         picture: String,
         subscriberCount: Int,
         subscribedCount: Int,
         postCount: Int,
         biography: String) {
        self.id = id
        self.username = username
        self.email = email
        self.picture = picture
        self.subscriberCount = subscriberCount
        self.subscribedCount = subscribedCount
        self.postCount = postCount
        self.biography = biography
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

    static var empty: Account {
        Account(
            id: 0,
            username: "",
            email: "",
            picture: "",
            subscriberCount: 0,
            subscribedCount: 0,
            postCount: 0,
            biography: ""
        )
    }
}
