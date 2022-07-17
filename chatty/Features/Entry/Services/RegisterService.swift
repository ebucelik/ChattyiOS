//
//  RegisterService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 17.07.22.
//

import Foundation

protocol RegisterServiceProtocol {
    func register(register: Register) async throws -> Account
}

class RegisterService: BackendClient, RegisterServiceProtocol {
    func register(register: Register) async throws -> Account {
        try await start(call: RegisterCall(body: register))
    }
}
