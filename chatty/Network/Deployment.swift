//
//  Environment.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import Foundation

enum Deployment: String {
    case dev = "http://localhost:8080/api/v1/"
    case prod = "https://chatty-bff.herokuapp.com/api/v1/"
}
