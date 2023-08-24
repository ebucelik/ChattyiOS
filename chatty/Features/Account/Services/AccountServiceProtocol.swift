//
//  AccountServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 15.01.23.
//

import Foundation

protocol AccountServiceProtocol {
    func getAccountBy(id: Int) async throws -> Account

    func deleteAccount(account: Account) async throws -> Message
}
