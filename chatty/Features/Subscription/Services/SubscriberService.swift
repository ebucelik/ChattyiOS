//
//  SubscriberService.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation
import ComposableArchitecture

class SubscriberService: BackendClient, SubscriberServiceProtocol {
    func getSubscriberBy(id: Int) async throws -> [Account] {
        let subscriberCall = SubscriberCall(parameters: ["id" : id])

        return try await sendRequest(call: subscriberCall)
    }

    func getSubscribedBy(id: Int) async throws -> [Account] {
        let subscribedCall = SubscribedCall(parameters: ["id" : id])

        return try await sendRequest(call: subscribedCall)
    }

    func getSubscriptionRequestsBy(id: Int) async throws -> [Account] {
        let subscriptionRequestCall = SubscriptionRequestCall(parameters: ["id" : id])

        return try await sendRequest(call: subscriptionRequestCall)
    }

    func subscribe(subscriber: Subscriber) async throws -> SubscriptionInfo {
        let subscribeCall = SubscribeCall(body: subscriber)

        return try await sendRequest(call: subscribeCall)
    }

    func subscriptionInfo(subscriber: Subscriber) async throws -> SubscriptionInfo {
        let subscriptionInfoCall = SubscriptionInfoCall(body: subscriber)

        return try await sendRequest(call: subscriptionInfoCall)
    }

    func acceptSubscription(subscriber: Subscriber) async throws -> Message {
        let acceptSubscriptionCall = AcceptSubscriptionCall(body: subscriber)

        return try await sendRequest(call: acceptSubscriptionCall)
    }

    func declineSubscription(subscriber: Subscriber) async throws -> Message {
        let declineSubscriptionCall = DeclineSubscriptionCall(body: subscriber)

        return try await sendRequest(call: declineSubscriptionCall)
    }
}

extension SubscriberService: DependencyKey {
    static let liveValue: SubscriberService = SubscriberService()
}
