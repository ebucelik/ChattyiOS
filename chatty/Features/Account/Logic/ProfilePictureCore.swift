//
//  ProfilePictureCore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 25.08.23.
//

import UIKit
import SwiftHelper
import ComposableArchitecture

struct ProfilePictureCore: Reducer {
    struct State: Equatable {
        var account: Account
        var accountState: Loadable<Account> = .none
        var pickedImage: UIImage? = nil

        init(account: Account) {
            self.account = account
        }
    }

    enum Action: Equatable {
        case updateImage
        case deleteImage
        case accountStateChanged(Loadable<Account>)

        case didImagePicked(UIImage)
        case didUpdatedImage

        case reset
    }

    @Dependency(\.accountService) var service
    @Dependency(\.imageService) var imageService

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .updateImage:
            guard let pickedImage = state.pickedImage else { return .none }

            return .run { [state = state] send in
                await send(.accountStateChanged(.loading))

                if let jpegData = pickedImage.jpegData(compressionQuality: 1.0) {
                    let pictureLink = try await self.imageService.uploadImage(imageData: jpegData)

                    let account = try await self.service.updateProfilePicture(
                        account: Account(
                            id: state.account.id,
                            username: state.account.username,
                            email: state.account.email,
                            picture: pictureLink,
                            subscriberCount: state.account.subscriberCount,
                            subscribedCount: state.account.subscribedCount,
                            postCount: state.account.postCount,
                            biography: state.account.biography
                        )
                    )

                    await send(.accountStateChanged(.loaded(account)))
                }
            } catch: { error, send in
                if let apiError = error as? APIError {
                    await send(.accountStateChanged(.error(apiError)))
                } else {
                    await send(.accountStateChanged(.error(.error(error))))
                }
            }

        case .deleteImage:
            state.account.picture = ""

            return .run { [state = state] send in
                await send(.accountStateChanged(.loading))

                let account = try await self.service.updateProfilePicture(account: state.account)

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
                return .send(.didUpdatedImage)
            }

            return .none

        case let .didImagePicked(image):
            state.pickedImage = image

            return .none

        case .didUpdatedImage:
            return .none

        case .reset:
            state.pickedImage = nil
            
            return .none
        }
    }
}
