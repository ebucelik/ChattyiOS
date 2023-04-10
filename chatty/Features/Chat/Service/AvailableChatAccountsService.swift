//
//  AvailableChatAccountsService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation
import ComposableArchitecture

class AvailableChatAccountsService: BackendClient, AvailableChatAccountsServiceProtocol {
    func getAvailableChatAccounts(by id: Int) async throws -> [Account] {
        let availableChatAccountsCall = AvailableChatAccountsCall(
            parameters: ["id": id]
        )

        return try await sendRequest(call: availableChatAccountsCall)
    }
}

extension AvailableChatAccountsService: DependencyKey {
    static let liveValue: AvailableChatAccountsService = AvailableChatAccountsService()
}
