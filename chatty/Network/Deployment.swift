//
//  Environment.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import Foundation

enum Deployment: String {
    case dev = "http://localhost:8080/api/v1/"
    case prod = "http://ec2-18-196-195-255.eu-central-1.compute.amazonaws.com:8080/api/v1/"
}
