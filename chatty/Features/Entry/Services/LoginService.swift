//
//  LoginService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 10.07.22.
//

import Foundation
import Combine
import ComposableArchitecture

protocol LoginServiceProtocol {
    func login(login: Login) async throws -> Account
}

class LoginService: BackendClient, LoginServiceProtocol, DependencyKey {
    static let liveValue = LoginService()

    func login(login: Login) async throws -> Account {
        try await self.start(call: LoginCall(body: login))
    }
}

extension DependencyValues {
    var loginService: LoginService {
        get { self[LoginService.self] }
        set { self[LoginService.self] = newValue }
    }

    var logoutService: LogoutService {
        get { self[LogoutService.self] }
        set { self[LogoutService.self] = newValue }
    }

    var registerService: RegisterService {
        get { self[RegisterService.self] }
        set { self[RegisterService.self] = newValue }
    }

    var accountAvailabilityService: AccountAvailabilityService {
        get { self[AccountAvailabilityService.self] }
        set { self[AccountAvailabilityService.self] = newValue }
    }

    var mainScheduler: DispatchQueue {
        get { self[DispatchQueue.self] }
        set { self[DispatchQueue.self] = newValue }
    }
}

extension DispatchQueue: DependencyKey {
    public static let liveValue = DispatchQueue.main
    public static let testValue = DispatchQueue.main
    public static let previewValue = DispatchQueue.main
}
