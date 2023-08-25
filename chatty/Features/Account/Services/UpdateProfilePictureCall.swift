//
//  UpdateProfilePictureCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 25.08.23.
//

import Foundation

struct UpdateProfilePictureCall: Call {
    typealias Response = Account

    var resource: String = "account/updateProfilePicture"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(account: Account) {
        self.body = account
    }
}
