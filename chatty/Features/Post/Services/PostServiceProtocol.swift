//
//  PostServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation

protocol PostServiceProtocol {
    func uploadPost(post: Post) async throws -> Message

    func deletePost(id: Int) async throws -> Message

    func fetchPostsBy(id: Int, userId: Int) async throws -> [Post]

    func fetchPostBy(id: Int, userId: Int) async throws -> Post

    func getAccountsFromPost(id: Int) async throws -> [Account]

    func saveLikeFromAccountToPost(postId: Int, userId: Int) async throws -> Message

    func removeLikeFromAccountToPost(postId: Int, userId: Int) async throws -> Message
}
