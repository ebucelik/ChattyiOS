//
//  BackendClient.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation
import Combine

class BackendClient {

    private let domain = "http://localhost:8080/api/v1/"

    private func start<C: Call>(call: C, completion: @escaping (Result<C.Response, Error>) -> Void) throws {

        guard let url = URL(string: domain + call.path) else {
            throw APIError.unexpectedError("URL is not valid or empty.")
        }

        // MARK: - Create request
        var request = URLRequest(url: url)
        request.httpMethod = call.httpMethod.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

        if let body = call.body {
            do {
                let httpBody = try JSONEncoder().encode(body)
                request.httpBody = httpBody
            } catch {
                throw APIError.error(error)
            }
        }

        // MARK: - Start call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("ERROR: \(error)")
                completion(.failure(error))
            } else {
                if let response = response as? HTTPURLResponse,
                   let headerFields = response.allHeaderFields as? [String: String],
                   let url = response.url {
                    let cookies: [HTTPCookie] = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
                    HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
                }

                if let data = data {
                    do {
                        let model = try JSONDecoder().decode(C.Response.self, from: data)
                        completion(.success(model))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
        .resume()
    }

    func start<C: Call>(call: C) async throws -> C.Response {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try start(call: call) { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)

                    case let .success(model):
                        continuation.resume(returning: model)
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
