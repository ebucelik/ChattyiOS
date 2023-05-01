//
//  ChatService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 02.05.23.
//

import ComposableArchitecture

class ChatService: BackendClient, ChatServiceProtocol {
    func getChat(for sessionId: Int) async throws -> [Chat] {
        let chatCall = ChatCall(
            parameters: [
                "sessionId": sessionId
            ]
        )

        return try await sendRequest(call: chatCall)
    }
}

extension ChatService: DependencyKey {
    static let liveValue: ChatService = ChatService()
}
