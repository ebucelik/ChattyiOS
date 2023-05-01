//
//  Chat.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation

struct Chat: Equatable, Identifiable, Codable {
    let id: Int
    let session: Int
    let toUserId: Int
    let message: String
    let timestamp: Double
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
