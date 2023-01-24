//
//  SubscriberServiceProtocol.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.01.23.
//

import Foundation

protocol SubscriberServiceProtocol {
    func getSubscribedBy(id: Int) async throws -> [Account]

    func getSubscriberBy(id: Int) async throws -> [Account]

    func getSubscriptionRequestsBy(id: Int) async throws -> [Account]

    func subscribe(subscriber: Subscriber) async throws -> SubscriptionInfo

    func subscriptionInfo(subscriber: Subscriber) async throws -> SubscriptionInfo

    func acceptSubscription(subscriber: Subscriber) async throws -> Message

    func declineSubscription(subscriber: Subscriber) async throws -> Message
}
