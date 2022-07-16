//
//  Call.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

protocol Call {
    associatedtype Response: Decodable

    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var body: Data? { get }
    var parameters: [String : Any]? { get }
}

extension Call {
    var body: Data? {
        get { nil }
    }
    var parameters: [String : Any]? {
        get { nil }
    }
}
