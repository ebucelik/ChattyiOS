//
//  ChatSession.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation

struct ChatSession: Equatable, Identifiable, Codable, Hashable {
    let id: Int
    let fromUserId: Int
    let toUserId: Int
    let username: String
    let picture: String
    let available: Bool
}

extension ChatSession {
    static var empty: ChatSession {
        ChatSession(
            id: 0,
            fromUserId: 0,
            toUserId: 0,
            username: "",
            picture: "",
            available: false
        )
    }
}
