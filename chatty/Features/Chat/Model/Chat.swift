//
//  Chat.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation

struct Chat: Equatable, Identifiable, Codable, Hashable {
    let id: Int
    var session: Int
    var toUserId: Int
    var message: String
    var timestamp: Double
}

extension Chat {
    static var empty: Chat {
        Chat(
            id: 0,
            session: 0,
            toUserId: 0,
            message: "",
            timestamp: 0.0
        )
    }
}
