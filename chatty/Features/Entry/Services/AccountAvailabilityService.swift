//
//  AccountAvailabilityService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 30.07.22.
//

import Foundation

protocol AccountAvailabilityProtocol {
    func checkUsername(username: String) async throws -> Bool
    func checkEmail(email: String) async throws -> Bool
}

class AccountAvailabilityService: BackendClient, AccountAvailabilityProtocol {
    func checkUsername(username: String) async throws -> Bool {
        try await start(call: AccountAvailabilityCall(parameters: ["username" : username]))
    }

    func checkEmail(email: String) async throws -> Bool {
        try await start(call: AccountAvailabilityCall(parameters: ["email" : email]))
    }
}
