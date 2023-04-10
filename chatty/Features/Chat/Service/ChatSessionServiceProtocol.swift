//
//  ChatSessionServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation

protocol ChatSessionServiceProtocol {
    func getChatSessions(fromUserId: Int) async throws -> [ChatSession]
}
