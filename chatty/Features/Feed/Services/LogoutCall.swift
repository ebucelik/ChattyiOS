//
//  LogoutCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.07.22.
//

import Foundation

class LogoutCall: Call {
    typealias Response = String

    let path: String = "logout"
    let httpMethod: HTTPMethod = .POST
}
