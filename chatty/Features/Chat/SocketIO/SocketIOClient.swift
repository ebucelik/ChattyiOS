//
//  SocketIOClient.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation
import SocketIO
import SwiftHelper

class SocketIOClient: NSObject {

    static let shared = SocketIOClient()

    private let dev = "localhost"
    private let prod = "85.215.128.216"
    private let manager: SocketManager
    private let socket: SocketIO.SocketIOClient
    private let event = "chat"

    override init() {
        self.manager = SocketManager(
            socketURL: URL(string: "http://\(prod):8085")!,
            config: [.log(true), .compress]
        )
        self.socket = manager.defaultSocket

        super.init()
    }

    deinit {
        disconnect()
    }

    public func connect() {
        self.socket.connect()
    }

    public func disconnect() {
        self.socket.disconnect()
    }

    public func createChatSession(chatSession: ChatSession) {
        let chatSessionJson: [String: Any] = [
            "fromUserId": chatSession.fromUserId,
            "toUserId": chatSession.toUserId
        ]

        socket.emit("createChatSession", chatSessionJson)
    }

    public func send(chat: Chat) {
        let chatJson: [String: Any] = [
            "session": chat.session,
            "toUserId": chat.toUserId,
            "message": chat.message,
            "timestamp": chat.timestamp
        ]

        socket.emit(event, chatJson)
    }

    public func receive(fromUserId: Int, toUserId: Int) {
        socket.on("\(fromUserId)") { data, _ in
            do {
                let jsonData = try JSONSerialization.data(
                    withJSONObject: data[0],
                    options: .prettyPrinted
                )

                let chat = try JSONDecoder().decode(
                    Chat.self,
                    from: jsonData
                )

                NotificationCenter.default.post(
                    name: .chat,
                    object: chat
                )
            } catch {
                print("Could not deserialize chat response.")
            }
        }

        socket.on("\(toUserId)") { data, _ in
            do {
                let jsonData = try JSONSerialization.data(
                    withJSONObject: data[0],
                    options: .prettyPrinted
                )

                let chat = try JSONDecoder().decode(
                    Chat.self,
                    from: jsonData
                )

                NotificationCenter.default.post(
                    name: .chat,
                    object: chat
                )
            } catch {
                print("Could not deserialize chat response.")
            }
        }
    }

    public func cancelListeners(fromUserId: Int, toUserId: Int) {
        socket.off("\(fromUserId)")
        socket.off("\(toUserId)")
    }
}
