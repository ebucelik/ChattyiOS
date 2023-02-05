//
//  UploadPostCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import SwiftUI
import ComposableArchitecture
import SwiftHelper

class UploadPostCore: ReducerProtocol {

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

        @BindableState var caption: String

        init(ownAccountId: Int? = nil,
             postState: Loadable<Message> = .none,
             pickedImage: UIImage? = nil,
             caption: String = "") {
            self.ownAccountId = ownAccountId
            self.postState = postState
            self.pickedImage = pickedImage
            self.caption = caption
        }
    }

    enum Action: BindableAction {
        case uploadPost
        case postStateChanged(Loadable<Message>)

        case setImage(UIImage)

        case binding(BindingAction<State>)

        case reset
        case resetted
    }

    @Dependency(\.postService) var service
    @Dependency(\.imageService) var imageService
    @Dependency(\.mainScheduler) var mainScheduler

    struct DebounceId: Hashable {}

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .uploadPost:
                return .task { [pickedImage = state.pickedImage,
                                ownAccountId = state.ownAccountId,
                                caption = state.caption] in

                    guard let ownAccountId = ownAccountId,
                          let postImage = pickedImage,
                          let jpegData = postImage.jpegData(compressionQuality: 1.0)
                    else {
                        return .postStateChanged(
                            .error(
                                APIError.unexpectedError("An error occured while uploading your post...")
                            )
                        )
                    }

                    let imageLink = try await self.imageService.uploadImage(imageData: jpegData)

                    let post = Post(
                        id: 0,
                        userId: ownAccountId,
                        imageLink: imageLink,
                        likesCount: 0,
                        caption: caption
                    )

                    let message = try await self.service.uploadPost(post: post)

                    return .postStateChanged(.loaded(message))
                } catch: { error in
                    if let apiError = error as? APIError {
                        return .postStateChanged(.error(apiError))
                    } else {
                        return .postStateChanged(.error(.error(error)))
                    }
                }
                .debounce(id: DebounceId(), for: 1, scheduler: self.mainScheduler)
                .receive(on: self.mainScheduler)
                .prepend(.postStateChanged(.loading))
                .eraseToEffect()

            case let .postStateChanged(postState):
                state.postState = postState

                return .none

            case let .setImage(pickedImage):
                state.pickedImage = pickedImage

                return .none

            case .binding:
                if state.caption.count >= state.textMaxLength {
                    state.caption = String(state.caption.prefix(state.textMaxLength))
                }

                return .none

            case .reset:
                state.pickedImage = nil
                state.caption = ""

                return .task {
                    return .resetted
                }
                .debounce(id: DebounceId(), for: 3, scheduler: self.mainScheduler)

            case .resetted:
                state.postState = .none

                return .none
            }
        }
    }
}
