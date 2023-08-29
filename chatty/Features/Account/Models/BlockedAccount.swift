//
//  BlockedAccount.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 29.08.23.
//

import Foundation

struct BlockedAccount: Codable, Equatable, Identifiable {
    let id: Int
    let userId: Int
    let blockedUserId: Int

    init(id: Int,
         userId: Int,
         blockedUserId: Int) {
        self.id = id
        self.userId = userId
        self.blockedUserId = blockedUserId
    }
}
