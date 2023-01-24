//
//  SearchService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.01.23.
//

import Foundation
import ComposableArchitecture

class SearchService: BackendClient, SearchServiceProtocol {
    func searchBy(username: String) async throws -> [Account] {
        let searchCall = SearchCall(parameters: ["username" : username])

        return try await sendRequest(call: searchCall)
    }
}

extension SearchService: DependencyKey {
    static let liveValue: SearchService = SearchService()
}
