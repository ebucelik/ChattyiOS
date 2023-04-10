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
