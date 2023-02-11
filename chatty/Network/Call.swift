//
//  Call.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

protocol Call {
    associatedtype Response: Codable

    var domain: String { get }
    var resource: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var body: Codable? { get }
    var parameters: [String : Any]? { get }
    var imageData: Data? { get }
}

extension Call {
    var domain: String { Deployment.dev.rawValue }

    var path: String { domain + resource}
    
    var body: Codable? {
        get { nil }
    }

    var parameters: [String : Any]? {
        get { nil }
    }

    var imageData: Data? {
        get { nil }
    }
}
