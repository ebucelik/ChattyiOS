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
    let manager = SocketManager(
        socketURL: URL(string: "http://ec2-52-59-224-51.eu-central-1.compute.amazonaws.com:8085")!,
        config: [.log(true), .compress]
    )
    let socket: SocketIO.SocketIOClient
    let event = "chat"
    var onChatReceive: (Chat) -> Void = { _ in }

    override init() {
        self.socket = manager.defaultSocket

        super.init()

        receive()
    }

    deinit {
        self.socket.disconnect()
    }

    public func connect() {
        self.socket.connect()
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
            "timestamp": Date.now.timeIntervalSinceReferenceDate
        ]

        socket.emit(event, chatJson)
    }

    public func receive() {
        socket.on(event) { data, _ in
            guard let chat = data[0] as? Chat else { return }

            self.onChatReceive(chat)
        }
    }
}
