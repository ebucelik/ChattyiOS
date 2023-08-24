//
//  DeleteAccountCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 24.08.23.
//

import Foundation

struct DeleteAccountCall: Call {
    typealias Response = Message

    var resource: String = "account"
    var httpMethod: HTTPMethod = .DELETE
    var body: Codable?

    init(account: Account) {
        self.body = account
    }
}
