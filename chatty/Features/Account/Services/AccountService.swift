//
//  AccountService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 15.01.23.
//

import Foundation
import ComposableArchitecture

class AccountService: BackendClient, AccountServiceProtocol {
    func getAccountBy(id: Int) async throws -> Account {
        let call = AccountCall(parameters: ["id" : id])

        return try await sendRequest(call: call)
    }
}

extension AccountService: DependencyKey {
    static let liveValue: AccountService = AccountService()
}
