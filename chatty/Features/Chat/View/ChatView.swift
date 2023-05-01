//
//  ChatView.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 01.05.23.
//

import Combine
import SwiftUI
import ComposableArchitecture

struct ChatView: View {
    private let store: StoreOf<ChatCore>
    private let chatPublisher = NotificationCenter
        .default
        .publisher(
            for: Notification.Name("chat")
        )

    init(store: StoreOf<ChatCore>) {
        self.store = store
    }

    var body: some View {
        EmptyView()
            .onReceive(chatPublisher) { publisher in
                print(publisher)
            }
    }
}
