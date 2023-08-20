//
//  Report.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.08.23.
//

import Foundation

struct Report: Codable, Equatable {
    let id: Int
    let postId: Int
    let reason: String

    init(id: Int,
         postId: Int,
         reason: String) {
        self.id = id
        self.postId = postId
        self.reason = reason
    }
}
