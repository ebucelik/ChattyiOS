//
//  AccountServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 15.01.23.
//

import Foundation

public protocol AccountServiceProtocol {
    func getAccountBy(id: Int) async throws -> Account
}
