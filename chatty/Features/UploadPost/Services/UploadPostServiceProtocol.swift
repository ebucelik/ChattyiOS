//
//  UploadPostServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import Foundation

protocol UploadPostServiceProtocol {
    func uploadPost(post: Post) async throws -> Message
}
