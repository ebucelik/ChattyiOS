//
//  AccountAvailabilityService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 30.07.22.
//

import Foundation
import ComposableArchitecture

protocol AccountAvailabilityProtocol {
    func checkUsername(username: String) async throws -> Bool
    func checkEmail(email: String) async throws -> Bool
}

class AccountAvailabilityService: BackendClient, AccountAvailabilityProtocol, DependencyKey {
    static let liveValue = AccountAvailabilityService()

    func checkUsername(username: String) async throws -> Bool {
        try await sendRequest(call: AccountAvailabilityCall(parameters: ["username" : username]))
    }

    func checkEmail(email: String) async throws -> Bool {
        try await sendRequest(call: AccountAvailabilityCall(parameters: ["email" : email]))
    }
}
