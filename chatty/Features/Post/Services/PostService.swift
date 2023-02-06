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

    func deletePost(id: Int) async throws -> Message {
        let deletePostCall = DeletePostCall(parameters: ["id" : id])

        return try await sendRequest(call: deletePostCall)
    }

    func fetchPostsBy(id: Int) async throws -> [Post] {
        let postsCall = PostsCall(parameters: ["id" : id])

        return try await sendRequest(call: postsCall)
    }

    func fetchPostBy(id: Int) async throws -> Post {
        let postCall = PostCall(parameters: ["id" : id])

        return try await sendRequest(call: postCall)
    }
}

extension PostService: DependencyKey {
    static let liveValue: PostService = PostService()
}
