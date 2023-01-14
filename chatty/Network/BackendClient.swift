//
//  BackendClient.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation
import SwiftHelper
import Combine
import Alamofire

class BackendClient {

    func sendRequest<C: Call>(call: C) async throws -> C.Response {
        return try await withCheckedThrowingContinuation { continuation in
            sendRequest(call: call) { result in
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

    private func sendRequest<C: Call>(call: C, completion: @escaping (Result<C.Response, Error>) -> Void) {

        // MARK: - Create URLComponents
        guard var components = URLComponents(string: call.path) else {
            completion(.failure(APIError.unexpectedError("URLCompontens are not valid or empty.")))
            return
        }

        if case .GET = call.httpMethod,
           let parameters = call.parameters {
            components.queryItems = parameters.compactMap { (key, value) in
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

        let request = createRequest(
            for: url,
            call: call
        )

#if DEBUG
        print("REQUEST URL: \(String(describing: url.absoluteString))")
#endif

        if let imageData = call.imageData,
           case .POST = call.httpMethod {
            // MARK: Start upload call
            AF.upload(
                multipartFormData: { multiPartFormData in
                    multiPartFormData.append(
                        imageData,
                        withName: FormData.withName,
                        fileName: FormData.fileName,
                        mimeType: FormData.mimeType
                    )
                },
                to: url.absoluteString,
                method: .post,
                headers: request.headers
            ).responseDecodable(of: C.Response.self) { dataResponse in
                if let error = dataResponse.error {
                    print("ERROR: \(error)")
                    completion(.failure(error))
                } else {
                    self.handleResponse(with: dataResponse.response,
                                        call: call,
                                        data: dataResponse.data,
                                        completion)
                }
            }
        } else {
            // MARK: Start call
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

                    self.handleResponse(with: response,
                                        call: call,
                                        data: data,
                                        completion)
                }
            }
            .resume()
        }
    }

    private func handleResponse<C: Call>(with response: URLResponse?,
                                         call: C,
                                         data: Data?,
                                         _ completion: @escaping (Result<C.Response, Error>) -> Void) {
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

    /// Creates an URLRequest object.
    /// - Parameters:
    ///   - url: To insert or get an object to or from the backend.
    ///   - httpMethod: Define the http method (e.g. GET, POST, PUT, DELETE).
    ///   - body: When a object should be inserted or updated at the backend.
    /// - Returns: URLRequest object
    private func createRequest(for url: URL, call: any Call) -> URLRequest {
        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = call.httpMethod.rawValue

        if call.imageData == nil {
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        }

        if let body = call.body {
            urlRequest.httpBody = try? JSONEncoder().encode(body)
        }

        return urlRequest
    }
}

extension BackendClient {
    func isStatusCodeValid(_ code: Int) -> Bool {
        (200..<399).contains(code)
    }
}
