//
//  LoginService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation
import Combine
import ComposableArchitecture

protocol LoginServiceProtocol {
    func login(login: Login) async throws -> Account
}

class LoginService: BackendClient, LoginServiceProtocol, DependencyKey {
    static let liveValue = LoginService()

    func login(login: Login) async throws -> Account {
        try await self.start(call: LoginCall(body: login))
    }
}
