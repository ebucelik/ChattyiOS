//
//  FeedPostsService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 08.04.23.
//

import Foundation
import ComposableArchitecture

class FeedPostsService: BackendClient, FeedPostsServiceProtocol {
    func getFeedPosts(for id: Int, limit: Int) async throws -> [Post] {
        let feedPostsCall = FeedPostsCall(
            parameters: [
                "id": id,
                "limit": limit
            ]
        )

        return try await sendRequest(call: feedPostsCall)
    }
}

extension FeedPostsService: DependencyKey {
    static let liveValue: FeedPostsService = FeedPostsService()
}
