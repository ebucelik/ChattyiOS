//
//  Message.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import Foundation

struct Message: Codable, Equatable {
    public let message: String

    init(message: String) {
        self.message = message
    }
}
