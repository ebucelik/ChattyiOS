//
//  UploadPostCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import SwiftUI
import ComposableArchitecture
import SwiftHelper

class UploadPostCore: Reducer {

    struct State: Equatable {
        var ownAccountId: Int?
        var postState: Loadable<Message>
        var pickedImage: UIImage?
        var textMaxLength = 60

        var approachesMaxLength: Bool {
            return caption.count >= textMaxLength - 10
        }

        var isImagePicked: Bool {
            return pickedImage != nil
        }

        @BindingState
        var caption: String

        @BindingState
        var showBanner: Bool

        var banner = Banner(
            title: "Upload sucessful",
            type: .success
        )

        init(ownAccountId: Int? = nil,
             postState: Loadable<Message> = .none,
             pickedImage: UIImage? = nil,
             caption: String = "",
             showBanner: Bool = false) {
            self.ownAccountId = ownAccountId
            self.postState = postState
            self.pickedImage = pickedImage
            self.caption = caption
            self.showBanner = showBanner
        }
    }

    enum Action: Equatable {
        case postStateChanged(Loadable<Message>)

        case view(View)

        public enum View: BindableAction, Equatable {
            case uploadPost

            case setImage(UIImage)

            case showBanner

            case binding(BindingAction<State>)

            case reset
            case resetted
        }
    }

    @Dependency(\.postService) var service
    @Dependency(\.imageService) var imageService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some Reducer<State, Action> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .view(.uploadPost):
                return .run { [pickedImage = state.pickedImage,
                               ownAccountId = state.ownAccountId,
                               caption = state.caption] send in
                    await send(.postStateChanged(.loading))

                    guard let ownAccountId = ownAccountId,
                          let postImage = pickedImage,
                          let jpegData = postImage.jpegData(compressionQuality: 1.0)
                    else {
                        await send(
                            .postStateChanged(
                                .error(
                                    APIError.unexpectedError("An error occured while uploading your post...")
                                )
                            )
                        )

                        return
                    }

                    let imageLink = try await self.imageService.uploadImage(imageData: jpegData)

                    let post = Post(
                        id: 0,
                        userId: ownAccountId,
                        imageLink: imageLink,
                        likesCount: 0,
                        caption: caption,
                        timestamp: Date.now.timeIntervalSinceReferenceDate,
                        likedByYou: false
                    )

                    let message = try await self.service.uploadPost(post: post)

                    await send(.postStateChanged(.loaded(message)))
                } catch: { error, send in
                    if let apiError = error as? APIError {
                        await send(.postStateChanged(.error(apiError)))
                    } else {
                        await send(.postStateChanged(.error(.error(error))))
                    }
                }
                .debounce(id: DebounceId(), for: 0.4, scheduler: self.mainScheduler)

            case let .postStateChanged(postState):
                state.postState = postState

                if case .loaded = postState {
                    state.banner = Banner(
                        title: "Upload successful",
                        type: .success
                    )

                    return .concatenate(
                        [
                            .send(.view(.showBanner)),
                            .send(.view(.reset))
                        ]
                    )
                } else if case .error = postState {
                    state.banner = Banner(
                        title: "Upload failed",
                        type: .error
                    )

                    return .concatenate(
                        [
                            .send(.view(.showBanner)),
                            .send(.view(.reset))
                        ]
                    )
                }

                return .none

            case let .view(.setImage(pickedImage)):
                state.pickedImage = pickedImage

                return .none

            case .view(.showBanner):
                state.showBanner = true

                return .none

            case .view(.binding):
                if state.caption.count >= state.textMaxLength {
                    state.caption = String(state.caption.prefix(state.textMaxLength))
                }

                return .none

            case .view(.reset):
                state.pickedImage = nil
                state.caption = ""

                return .send(.view(.resetted))
                .debounce(id: DebounceId(), for: 3, scheduler: self.mainScheduler)

            case .view(.resetted):
                state.postState = .none
                state.showBanner = false

                return .none
            }
        }
    }
}
