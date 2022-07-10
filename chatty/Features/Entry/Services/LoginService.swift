//
//  LoginService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation
import Combine

protocol LoginServiceProtocol {
    func login(login: Login) -> AnyPublisher<Account, Error>
}

class LoginService: BackendClient, LoginServiceProtocol {
    func login(login: Login) -> AnyPublisher<Account, Error> {
        Deferred {
            Future { promise in
                Task.init {
                    do {
                        promise(.success(try await self.start(call: LoginCall(body: login))))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
