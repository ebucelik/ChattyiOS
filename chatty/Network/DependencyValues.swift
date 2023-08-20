//
//  DependencyValues.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 07.01.23.
//

import Foundation
import ComposableArchitecture

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

    var imageService: ImageService {
        get { self[ImageService.self] }
        set { self[ImageService.self] = newValue }
    }

    var accountService: AccountService {
        get { self[AccountService.self] }
        set { self[AccountService.self] = newValue }
    }

    var subscriberService: SubscriberService {
        get { self[SubscriberService.self] }
        set { self[SubscriberService.self] = newValue }
    }

    var searchService: SearchService {
        get { self[SearchService.self] }
        set { self[SearchService.self] = newValue }
    }

    var postService: PostService {
        get { self[PostService.self] }
        set { self[PostService.self] = newValue }
    }

    var feedPostsService: FeedPostsService {
        get { self[FeedPostsService.self] }
        set { self[FeedPostsService.self] = newValue }
    }

    var chatSessionService: ChatSessionService {
        get { self[ChatSessionService.self] }
        set { self[ChatSessionService.self] = newValue }
    }

    var availableChatAccountsService: AvailableChatAccountsService {
        get { self[AvailableChatAccountsService.self] }
        set { self[AvailableChatAccountsService.self] = newValue }
    }

    var chatService: ChatService {
        get { self[ChatService.self] }
        set { self[ChatService.self] = newValue }
    }

    var reportService: ReportService {
        get { self[ReportService.self] }
        set { self[ReportService.self] = newValue }
    }

    var mainScheduler: DispatchQueue {
        get { self[DispatchQueue.self] }
        set { self[DispatchQueue.self] = newValue }
    }
}
