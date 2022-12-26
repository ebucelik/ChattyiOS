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

        // MARK: - Create URLComponents
        guard var components = URLComponents(string: domain + call.path) else {
            completion(.failure(APIError.unexpectedError("URLCompontens are not valid or empty.")))
            return
        }

        if case .GET = call.httpMethod {
            components.queryItems = call.parameters?.compactMap { (key, value) in
                if let valueString = value as? String {
                    return URLQueryItem(name: key, value: valueString)
                }

                return nil
            }

            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }

        guard let url = components.url else {
            completion(.failure(APIError.unexpectedError("URL is not valid or empty.")))
            return
        }

        let request = createRequest(for: url, httpMethod: call.httpMethod, body: call.body)

#if DEBUG
        print("REQUEST URL: \(String(describing: url.absoluteString))")
#endif

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
                        Account.removeFromUserDefaults()
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


    /// Creates an URLRequest object.
    /// - Parameters:
    ///   - url: To insert or get an object to or from the backend.
    ///   - httpMethod: Define the http method (e.g. GET, POST, PUT, DELETE).
    ///   - body: When a object should be inserted or updated at the backend.
    /// - Returns: URLRequest object
    private func createRequest(for url: URL, httpMethod: HTTPMethod, body: Data? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

        if let body = body {
            urlRequest.httpBody = body
        }

        return urlRequest
    }
}

extension BackendClient {
    func isStatusCodeValid(_ code: Int) -> Bool {
        (200..<399).contains(code)
    }
}
