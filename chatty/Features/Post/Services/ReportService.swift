//
//  ReportService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 20.08.23.
//

import Foundation
import ComposableArchitecture

class ReportService: BackendClient, ReportServiceProtocol {
    func report(report: Report) async throws -> Report {
        let reportCall = ReportCall(body: report)

        return try await sendRequest(call: reportCall)
    }
}

extension ReportService: DependencyKey {
    static var liveValue: ReportService = ReportService()
    static var testValue: ReportService = ReportService()
}
