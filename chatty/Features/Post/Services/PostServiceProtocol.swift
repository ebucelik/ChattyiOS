//
//  PostServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation

protocol PostServiceProtocol {
    func uploadPost(post: Post) async throws -> Message

    func fetchPostsBy(id: Int) async throws -> [Post]

    func fetchPostBy(id: Int) async throws -> Post
}
