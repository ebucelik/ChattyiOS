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
    let manager = SocketManager(socketURL: URL(string: "http://localhost:8085")!, config: [.log(true), .compress])
    let socket: SocketIO.SocketIOClient

    override init() {
        self.socket = manager.defaultSocket

        super.init()

        socket.on(clientEvent: .connect) { data, ack in
            print(data)
        }
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
}
