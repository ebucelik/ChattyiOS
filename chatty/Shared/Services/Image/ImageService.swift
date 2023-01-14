//
//  ImageService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 07.01.23.
//

import Foundation
import ComposableArchitecture

class ImageService: BackendClient, ImageServiceProtocol, DependencyKey {
    static let liveValue: ImageService = ImageService()

    func uploadImage(imageData: Data) async throws -> String {
        let call = ImageCall(imageData: imageData)

        return try await sendRequest(call: call)
    }
}
