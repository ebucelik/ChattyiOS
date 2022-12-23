//
//  ErrorMessage.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import Foundation

struct ErrorMessage: Decodable {
    public let message: String

    init(message: String) {
        self.message = message
    }
}
