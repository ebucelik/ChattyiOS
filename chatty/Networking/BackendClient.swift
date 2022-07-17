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

    private func start<C: Call>(call: C, completion: @escaping (Result<C.Response, Error>) -> Void) {

        guard let url = URL(string: domain + call.path) else {
            completion(.failure(APIError.unexpectedError("URL is not valid or empty.")))
            return
        }

        // MARK: - Create request
        var request = URLRequest(url: url)
        request.httpMethod = call.httpMethod.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

        if let body = call.body {
            request.httpBody = body
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

                if let data = data,
                   let response = response as? HTTPURLResponse {
                    if self.isStatusCodeValid(response.statusCode) {
                        do {
                            let model = try JSONDecoder().decode(C.Response.self, from: data)
                            completion(.success(model))
                        } catch {
                            completion(.failure(error))
                        }
                    } else if response.statusCode == 401 {
                        Account.removeUserDefaults()
                        completion(.failure(APIError.unauthorized))
                    } else {
                        do {
                            let errorModel = try JSONDecoder().decode(ErrorMessage.self, from: data)
                            completion(.failure(APIError.unexpectedError(errorModel.message)))
                        } catch {
                            completion(.failure(APIError.error(error)))
                        }
                    }
                } else {
                    completion(.failure(APIError.unexpectedError("Data is corrupt.")))
                }
            }
        }
        .resume()
    }

    func start<C: Call>(call: C) async throws -> C.Response {
        return try await withCheckedThrowingContinuation { continuation in
            start(call: call) { result in
                switch result {
                case let .failure(error):
                    if let apiError = error as? APIError {
                        continuation.resume(throwing: apiError)
                    } else {
                        continuation.resume(throwing: error)
                    }

                case let .success(model):
                    continuation.resume(returning: model)
                }
            }
        }
    }
}

extension BackendClient {
    func isStatusCodeValid(_ code: Int) -> Bool {
        (200..<399).contains(code)
    }
}
