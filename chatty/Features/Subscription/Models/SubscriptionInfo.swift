//
//  SubscriptionInfo.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 19.01.23.
//

import Foundation

struct SubscriptionInfo: Codable, Equatable {
    let status: String
    let accepted: Bool

    init(status: String, accepted: Bool) {
        self.status = status
        self.accepted = accepted
    }
}
