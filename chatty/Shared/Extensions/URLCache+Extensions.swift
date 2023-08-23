//
//  URLCache+Extensions.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 23.08.23.
//

import Foundation

public extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512_000_000, diskCapacity: 10_000_000_000)
}
