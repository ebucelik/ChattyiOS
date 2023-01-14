//
//  ImageServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 07.01.23.
//

import Foundation

protocol ImageServiceProtocol {
    func uploadImage(imageData: Data) async throws -> String
}
