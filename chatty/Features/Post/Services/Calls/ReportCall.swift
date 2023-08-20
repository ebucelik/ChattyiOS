//
//  ReportCall.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.08.23.
//

import Foundation

struct ReportCall: Call {
    typealias Response = Report

    var resource: String = "report"
    var httpMethod: HTTPMethod = .POST
    var body: Codable?

    init(body: Report) {
        self.body = body
    }
}
