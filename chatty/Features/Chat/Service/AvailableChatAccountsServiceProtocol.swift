//
//  AvailableChatAccountsServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.04.23.
//

import Foundation

protocol AvailableChatAccountsServiceProtocol {
    func getAvailableChatAccounts(by id: Int) async throws -> [Account]
}
