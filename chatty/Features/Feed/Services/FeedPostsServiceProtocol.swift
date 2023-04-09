//
//  FeedPostsServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.04.23.
//

import Foundation

protocol FeedPostsServiceProtocol {
    func getFeedPosts(for id: Int, limit: Int) async throws -> [Post]
}
