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

    func fetchPostsBy(id: Int, userId: Int) async throws -> [Post] {
        let postsCall = PostsCall(
            parameters: [
                "id" : id,
                "userId": userId
            ]
        )

        return try await sendRequest(call: postsCall)
    }

    func fetchPostBy(id: Int, userId: Int) async throws -> Post {
        let postCall = PostCall(
            parameters: [
                "id" : id,
                "userId": userId
            ]
        )

        return try await sendRequest(call: postCall)
    }

    func getAccountsFromPost(id: Int) async throws -> [Account] {
        let getAccountsFromPostCall = GetAccountsFromPostCall(parameters: ["id" : id])

        return try await sendRequest(call: getAccountsFromPostCall)
    }

    func saveLikeFromAccountToPost(postId: Int, userId: Int) async throws -> Message {
        let likePostCall = LikePostCall(
            parameters: [
                "postId" : postId,
                "userId" : userId
            ]
        )

        return try await sendRequest(call: likePostCall)
    }

    func removeLikeFromAccountToPost(postId: Int, userId: Int) async throws -> Message {
        let removeLikePostCall = RemoveLikePostCall(
            parameters: [
                "postId" : postId,
                "userId" : userId
            ]
        )

        return try await sendRequest(call: removeLikePostCall)
    }
}

extension PostService: DependencyKey {
    static let liveValue: PostService = PostService()
}
