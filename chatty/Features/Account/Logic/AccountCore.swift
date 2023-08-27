//
//  AccountCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 29.12.22.
//

import Foundation
import OneSignalFramework
import SwiftHelper
import ComposableArchitecture

class AccountCore: Reducer {

    struct State: Equatable, Identifiable {
        var id: Int
        var ownAccountId: Int?
        var ownAccount: Account?
        var accountState: Loadable<Account>
        var subscriberState: Loadable<[Account]>
        var subscribedState: Loadable<[Account]>
        var subscribeState: Loadable<Subscriber>
        var subscriptionInfoState: Loadable<SubscriptionInfo>
        var postsState: Loadable<[Post]>

        var subscriptionRequestCoreState: SubscriptionRequestCore.State?

        var subscriberCoreState: SubscriptionCore.State
        var subscribedCoreState: SubscriptionCore.State

        var profilePictureCoreState: ProfilePictureCore.State

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

        @BindingState
        var showDeleteAlert: Bool = false

        var showPrivacyPolicyWebView: Bool = false

        init(ownAccountId: Int? = nil,
             ownAccount: Account? = nil,
             accountState: Loadable<Account> = .none,
             subscriberState: Loadable<[Account]> = .none,
             subscribedState: Loadable<[Account]> = .none,
             subscribeState: Loadable<Subscriber> = .none,
             subscriptionInfoState: Loadable<SubscriptionInfo> = .none,
             postsState: Loadable<[Post]> = .none) {
            self.accountState = accountState
            self.ownAccount = ownAccount
            self.subscriberState = subscriberState
            self.subscribedState = subscribedState
            self.subscribeState = subscribeState
            self.subscriptionInfoState = subscriptionInfoState
            self.postsState = postsState

            guard case let .loaded(account) = accountState else {
                self.id = ownAccountId ?? 0
                self.ownAccountId = nil
                self.subscriberCoreState = SubscriptionCore.State(
                    ownAccountId: ownAccountId ?? 0,
                    ownAccount: .empty,
                    accounts: [],
                    subscriptionMode: .subscriber
                )

                self.subscribedCoreState = SubscriptionCore.State(
                    ownAccountId: ownAccountId ?? 0,
                    ownAccount: .empty,
                    accounts: [],
                    subscriptionMode: .subscribed
                )

                self.profilePictureCoreState = ProfilePictureCore.State(account: .empty)

                return
            }

            self.subscriptionRequestCoreState = SubscriptionRequestCore.State(
                ownAccount: account
            )

            if let ownAccountId = ownAccountId,
               account.id != ownAccountId {
                self.ownAccountId = ownAccountId
                self.id = account.id
            } else {
                self.id = ownAccountId ?? 0
            }

            self.subscriberCoreState = SubscriptionCore.State(
                ownAccountId: self.id,
                ownAccount: account,
                accounts: [],
                subscriptionMode: .subscriber
            )

            self.subscribedCoreState = SubscriptionCore.State(
                ownAccountId: self.id,
                ownAccount: account,
                accounts: [],
                subscriptionMode: .subscribed
            )

            self.profilePictureCoreState = ProfilePictureCore.State(account: account)
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

        case subscription(SubscriptionCore.Action)

        case profilePicture(ProfilePictureCore.Action)

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

            case didDeleteAccount
            case didDeleteAccountTapped

            case setShowPrivacyPolicyWebView(Bool)

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

        Scope(
            state: \.subscriberCoreState,
            action: /Action.subscription
        ) {
            SubscriptionCore()
        }

        Scope(
            state: \.subscribedCoreState,
            action: /Action.subscription
        ) {
            SubscriptionCore()
        }

        Scope(
            state: \.profilePictureCoreState,
            action: /Action.profilePicture) {
                ProfilePictureCore()
            }

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

                if case let .loaded(account) = accountState {
                    state.profilePictureCoreState = ProfilePictureCore.State(account: account)

                    return .merge(
                        [
                            .send(.fetchSubscriberInfo),
                            state.isOtherAccount ? .send(.view(.fetchSubscriptionInfo)) : .none,
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

                if case let .loaded(subscriberAccounts) = subscriberState,
                   case let .loaded(account) = state.accountState {
                    state.subscriberCoreState = SubscriptionCore.State(
                        ownAccountId: account.id,
                        ownAccount: account,
                        accounts: subscriberAccounts,
                        subscriptionMode: .subscriber
                    )
                }

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

                if case let .loaded(subscribedAccounts) = subscribedState,
                   case let .loaded(account) = state.accountState {
                    state.subscribedCoreState = SubscriptionCore.State(
                        ownAccountId: account.id,
                        ownAccount: account,
                        accounts: subscribedAccounts,
                        subscriptionMode: .subscribed
                    )
                }

                return .none

            case .subscription:
                return .none

            case .profilePicture(.didUpdatedImage):
                return .send(.view(.fetchAccount))

            case .profilePicture:
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

                guard let ownAccount = state.ownAccount,
                      case let .loaded(account) = state.accountState
                else { return .none }

                return .run { send in
                    let subscriber = Subscriber(userId: ownAccount.id, subscribedUserId: account.id)
                    let subscriptionInfo = try await self.subscriberService.subscribe(subscriber: subscriber)

                    OneSignalClient.shared.sendPush(
                        with: " would like to subscribe you.",
                        username: "@\(ownAccount.username)",
                        title: "",
                        accountId: account.id
                    )

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
                OneSignal.logout()

                return .none

            case .view(.didDeleteAccount):
                guard case let .loaded(account) = state.accountState else { return .none }

                return .run { send in
                    _ = try await self.service.deleteAccount(account: account)

                    await send(.view(.loggedOut))
                }

            case .view(.didDeleteAccountTapped):
                state.showDeleteAlert = true

                return .none

            case let .view(.setShowPrivacyPolicyWebView(value)):
                state.showPrivacyPolicyWebView = value

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
