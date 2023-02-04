//
//  UploadPostService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation
import ComposableArchitecture

class UploadPostService: BackendClient, UploadPostServiceProtocol {
    func uploadPost(post: Post) async throws -> Message {
        let uploadPostCall = UploadPostCall(body: post)

        return try await sendRequest(call: uploadPostCall)
    }
}

extension UploadPostService: DependencyKey {
    static let liveValue: UploadPostService = UploadPostService()
}
