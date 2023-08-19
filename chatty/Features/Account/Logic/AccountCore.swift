//
//  AccountCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 29.12.22.
//

import Foundation
import SwiftHelper
import ComposableArchitecture

class AccountCore: Reducer {

    struct State: Equatable, Identifiable {
        var id: Int
        var ownAccountId: Int?
        var accountState: Loadable<Account>
        var subscriberState: Loadable<[Account]>
        var subscribedState: Loadable<[Account]>
        var subscribeState: Loadable<Subscriber>
        var subscriptionInfoState: Loadable<SubscriptionInfo>
        var postsState: Loadable<[Post]>

        var subscriptionRequestCoreState: SubscriptionRequestCore.State?

        var isOtherAccount: Bool {
            ownAccountId != nil
        }

        var accountId: Int? {
            if case let .loaded(account) = accountState {
                return account.id
            }

            return nil
        }

        var newUpdatesAvailable: Bool = false

        @BindingState
        var showMore: Bool = false

        init(ownAccountId: Int? = nil,
             accountState: Loadable<Account> = .none,
             subscriberState: Loadable<[Account]> = .none,
             subscribedState: Loadable<[Account]> = .none,
             subscribeState: Loadable<Subscriber> = .none,
             subscriptionInfoState: Loadable<SubscriptionInfo> = .none,
             postsState: Loadable<[Post]> = .none) {
            self.accountState = accountState
            self.subscriberState = subscriberState
            self.subscribedState = subscribedState
            self.subscribeState = subscribeState
            self.subscriptionInfoState = subscriptionInfoState
            self.postsState = postsState

            guard case let .loaded(account) = accountState else {
                self.id = ownAccountId ?? 0
                self.ownAccountId = nil
                return
            }

            self.subscriptionRequestCoreState = SubscriptionRequestCore.State(ownAccountId: account.id)

            if let ownAccountId = ownAccountId,
               account.id != ownAccountId {
                self.ownAccountId = ownAccountId
                self.id = account.id
            } else {
                self.id = ownAccountId ?? 0
            }
        }
    }

    enum Action: Equatable {
        case fetchSubscriberInfo

        case accountStateChanged(Loadable<Account>)

        case fetchSubscriber
        case subscriberStateChanged(Loadable<[Account]>)

        case fetchSubscribed
        case subscribedStateChanged(Loadable<[Account]>)

        case subscriptionInfoChanged(Loadable<SubscriptionInfo>)

        case fetchPosts
        case sendPostsRequest(Int)
        case postsStateChanged(Loadable<[Post]>)

        case subscriptionRequest(SubscriptionRequestCore.Action)

        case view(View)

        public enum View: BindableAction, Equatable {
            case fetchAccount

            case fetchSubscriptionInfo
            case sendSubscriptionRequest
            case declineOrCancelSubscriptionRequest

            case toggleNewUpdatesAvailable

            case showMore

            case logout
            case loggedOut

            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.accountService) var service
    @Dependency(\.subscriberService) var subscriberService
    @Dependency(\.postService) var postService
    @Dependency(\.logoutService) var logoutService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .fetchSubscriberInfo:
                return .merge(
                    [
                        .send(.fetchSubscriber),
                        .send(.fetchSubscribed)
                    ]
                )

            case .view(.fetchAccount):
                guard case let .loaded(account) = state.accountState else { return .none }

                return .run { [id = account.id] send in
                    let account = try await self.service.getAccountBy(id: id)

                    await send(.accountStateChanged(.loaded(account)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.accountStateChanged(.error(apiError)))
                    } else {
                        await send(.accountStateChanged(.error(.error(error))))
                    }
                }

            case let .accountStateChanged(accountState):
                state.accountState = accountState

                if case .loaded = accountState {
                    return .merge(
                        [
                            .send(.fetchSubscriberInfo),
                            .send(.fetchPosts)
                        ]
                    )
                }

                return .none

            case .fetchSubscriber:

                guard case let .loaded(account) = state.accountState,
                      !state.isOtherAccount
                else { return .none }

                return .run { [id = account.id] send in
                    await send(.subscriberStateChanged(.loading))

                    let subscriberAccounts = try await self.subscriberService.getSubscriberBy(id: id)

                    await send(.subscriberStateChanged(.loaded(subscriberAccounts)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.subscriberStateChanged(.error(apiError)))
                    } else {
                        await send(.subscriberStateChanged(.error(.error(error))))
                    }
                }

            case let .subscriberStateChanged(subscriberState):
                state.subscriberState = subscriberState

                return .none

            case .fetchSubscribed:

                guard case let .loaded(account) = state.accountState,
                      !state.isOtherAccount
                else { return .none }

                return .run { [id = account.id] send in
                    await send(.subscribedStateChanged(.loading))

                    let subscribedAccounts = try await self.subscriberService.getSubscribedBy(id: id)

                    await send(.subscribedStateChanged(.loaded(subscribedAccounts)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.subscribedStateChanged(.error(apiError)))
                    } else {
                        await send(.subscribedStateChanged(.error(.error(error))))
                    }
                }

            case let .subscribedStateChanged(subscribedState):
                state.subscribedState = subscribedState

                return .none

            case .view(.fetchSubscriptionInfo):
                guard let ownAccountId = state.ownAccountId,
                      case let .loaded(account) = state.accountState else { return .none }

                return .run { send in
                    await send(.subscriptionInfoChanged(.loading))

                    let subscriber = Subscriber(userId: ownAccountId, subscribedUserId: account.id)
                    let subscriptionInfo = try await self.subscriberService.subscriptionInfo(subscriber: subscriber)

                    await send(.subscriptionInfoChanged(.loaded(subscriptionInfo)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.subscriptionInfoChanged(.error(apiError)))
                    } else {
                        await send(.subscriptionInfoChanged(.error(.error(error))))
                    }
                }

            case .view(.sendSubscriptionRequest):

                guard let ownAccountId = state.ownAccountId,
                      case let .loaded(account) = state.accountState
                else { return .none }

                return .run { send in
                    let subscriber = Subscriber(userId: ownAccountId, subscribedUserId: account.id)
                    let subscriptionInfo = try await self.subscriberService.subscribe(subscriber: subscriber)

                    await send(.subscriptionInfoChanged(.loaded(subscriptionInfo)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.subscriptionInfoChanged(.error(apiError)))
                    } else {
                        await send(.subscriptionInfoChanged(.error(.error(error))))
                    }
                }

            case .view(.declineOrCancelSubscriptionRequest):

                guard let ownAccountId = state.ownAccountId,
                      case let .loaded(account) = state.accountState,
                      case let .loaded(subscriptionInfo) = state.subscriptionInfoState
                else { return .none }

                return .run { send in
                    let subscriber = Subscriber(userId: ownAccountId, subscribedUserId: account.id)

                    if subscriptionInfo.accepted {
                        _ = try await self.subscriberService.cancelSubscription(subscriber: subscriber)
                    } else {
                        _ = try await self.subscriberService.declineSubscription(subscriber: subscriber)
                    }

                    await send(.view(.fetchSubscriptionInfo))
                }

            case let .subscriptionInfoChanged(subscriptionInfoState):
                state.subscriptionInfoState = subscriptionInfoState
                
                if case let .loaded(subscriptionInfo) = subscriptionInfoState,
                   subscriptionInfo.accepted {
                    return .send(.fetchPosts)
                }

                return .none

            case .fetchPosts:
                if state.isOtherAccount {
                    if case let .loaded(subscriptionInfo) = state.subscriptionInfoState,
                       subscriptionInfo.accepted,
                       case let .loaded(account) = state.accountState {
                        return .send(.sendPostsRequest(account.id))
                    } else {
                        return .send(.postsStateChanged(.none))
                    }
                } else if case let .loaded(account) = state.accountState {
                    return .send(.sendPostsRequest(account.id))
                }

                return .none

            case let .sendPostsRequest(id):

                var accountId = 0

                if state.isOtherAccount,
                   let ownAccountId = state.ownAccountId {
                    accountId = ownAccountId
                } else if let stateAccountId = state.accountId {
                    accountId = stateAccountId
                }

                return .run { [accountId = accountId] send in
                    let posts = try await self.postService.fetchPostsBy(
                        id: id,
                        userId: accountId
                    )

                    await send(.postsStateChanged(.loaded(posts)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.postsStateChanged(.error(apiError)))
                    } else {
                        await send(.postsStateChanged(.error(.error(error))))
                    }
                }

            case let .postsStateChanged(postsState):
                state.postsState = postsState

                return .none

            case .view(.toggleNewUpdatesAvailable):
                state.newUpdatesAvailable.toggle()

                return .none

            case .view(.showMore):
                state.showMore.toggle()

                return .none

            case .view(.logout):
                return .run { send in
                    _ = try await self.logoutService.logout()

                    await send(.view(.loggedOut))
                } catch: { _, send in
                    await send(.view(.loggedOut))
                }
                .debounce(id: DebounceId(), for: 0.4, scheduler: self.mainScheduler)

            case .view(.loggedOut):
                return .none

            case .view(.binding):
                return .none

                // MARK: SubscriptionRequestCore
            case .subscriptionRequest(.subscriptionAccepted):
                return .send(.view(.toggleNewUpdatesAvailable))

            case .subscriptionRequest:
                return .none
            }
        }
        .ifLet(\.subscriptionRequestCoreState, action: /Action.subscriptionRequest) {
            SubscriptionRequestCore()
        }
    }
}
