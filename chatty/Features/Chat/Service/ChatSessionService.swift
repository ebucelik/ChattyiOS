//
//  ChatSessionService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation
import ComposableArchitecture

class ChatSessionService: BackendClient, ChatSessionServiceProtocol {
    func getChatSessions(fromUserId: Int) async throws -> [ChatSession] {
        let chatSessionCall = ChatSessionCall(
            parameters: ["fromUserId": fromUserId]
        )

        return try await sendRequest(call: chatSessionCall)
    }
}

extension ChatSessionService: DependencyKey {
    static let liveValue: ChatSessionService = ChatSessionService()
}
