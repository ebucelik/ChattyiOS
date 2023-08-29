//
//  BlockedAccountCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 29.08.23.
//

import Foundation

struct BlockedAccountCall: Call {
    typealias Response = BlockedAccount

    var resource: String = "account/blockAccount"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(blockedAccount: BlockedAccount) {
        self.body = blockedAccount
    }
}
