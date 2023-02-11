//
//  LogoutServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import Foundation

protocol LogoutServiceProtocol {
    func logout() async throws -> String
}
