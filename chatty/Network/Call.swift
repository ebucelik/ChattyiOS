//
//  Call.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

protocol Call {
    associatedtype Response: Codable

    var scheme: String { get }
    var domain: String { get }
    var resource: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var body: Codable? { get }
    var parameters: [String : Any]? { get }
    var imageData: Data? { get }
}

extension Call {
    var scheme: String { "http://" }

    var domain: String { "192.168.1.10:8080/api/v1/" }

    var path: String { scheme + domain + resource}
    
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
