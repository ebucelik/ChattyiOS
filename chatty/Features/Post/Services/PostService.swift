//
//  PostService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation
import ComposableArchitecture

class PostService: BackendClient, PostServiceProtocol {
    func uploadPost(post: Post) async throws -> Message {
        let uploadPostCall = UploadPostCall(body: post)

        return try await sendRequest(call: uploadPostCall)
    }

    func fetchPostsBy(id: Int) async throws -> [Post] {
        let fetchPostsCall = FetchPostsCall(parameters: ["id" : id])

        return try await sendRequest(call: fetchPostsCall)
    }
}

extension PostService: DependencyKey {
    static let liveValue: PostService = PostService()
}
