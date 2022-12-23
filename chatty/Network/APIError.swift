//
//  APIError.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation

enum APIError: Error {
    case unauthorized, notFound, notModified, error(Error), unexpectedError(String)
}
