//
//  ReportServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.08.23.
//

import Foundation

protocol ReportServiceProtocol {
    func report(report: Report) async throws -> Report
}
