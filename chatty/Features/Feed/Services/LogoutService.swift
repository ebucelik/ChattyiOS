//
//  LogoutService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.07.22.
//

import Foundation
import ComposableArchitecture

protocol LogoutServiceProtocol {
    func logout() async throws -> String
}

class LogoutService: BackendClient, LogoutServiceProtocol, DependencyKey {
    static let liveValue = LogoutService()

    func logout() async throws -> String {
        return try await self.start(call: LogoutCall())
    }
}
