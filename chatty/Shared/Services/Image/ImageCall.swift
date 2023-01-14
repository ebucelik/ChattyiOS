//
//  ImageCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 07.01.23.
//

import Foundation

struct ImageCall: Call {
    typealias Response = String

    let resource: String = "image/upload"
    let httpMethod: HTTPMethod = .POST
    let imageData: Data?

    init(imageData: Data) {
        self.imageData = imageData
    }
}
