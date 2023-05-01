//
//  ChatServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 02.05.23.
//

import Foundation

protocol ChatServiceProtocol {
    func getChat(for sessionId: Int) async throws -> [Chat]
}
