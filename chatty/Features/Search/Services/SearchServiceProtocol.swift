//
//  SearchServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.01.23.
//

import Foundation

protocol SearchServiceProtocol {
    func searchBy(username: String) async throws -> [Account]
}
