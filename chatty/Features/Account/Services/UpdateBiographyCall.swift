//
//  UpdateBiographyCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 26.08.23.
//

import Foundation

struct UpdateBiographyCall: Call {
    typealias Response = Account

    var resource: String = "account/updateBiography"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(account: Account) {
        self.body = account
    }
}
