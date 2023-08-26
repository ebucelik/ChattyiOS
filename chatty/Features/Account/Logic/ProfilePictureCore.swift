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
        var biography: String
        var textMaxLength = 60

        var approachesMaxLength: Bool {
            return biography.count >= textMaxLength - 10
        }

        var didImagePickedOrBiographyChanged: Bool {
            pickedImage != nil || didBiographyChanged
        }

        var didBiographyChanged: Bool {
            biography != account.biography
        }

        init(account: Account) {
            self.account = account
            self.biography = account.biography
        }
    }

    enum Action: Equatable {
        case updateImage
        case deleteImage
        case accountStateChanged(Loadable<Account>)

        case didImagePicked(UIImage)
        case didUpdatedImage

        case setBiography(String)

        case reset
    }

    @Dependency(\.accountService) var service
    @Dependency(\.imageService) var imageService

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .updateImage:
            guard state.pickedImage != nil || state.biography != state.account.biography
            else { return .none }

            return .run { [state = state] send in
                await send(.accountStateChanged(.loading))

                if let pickedImage = state.pickedImage,
                    let jpegData = pickedImage.jpegData(compressionQuality: 1.0) {
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

                    if state.biography != account.biography {
                        let biographyChangedAccount = try await self.service.updateBiography(
                            account: Account(
                                id: state.account.id,
                                username: state.account.username,
                                email: state.account.email,
                                picture: account.picture,
                                subscriberCount: state.account.subscriberCount,
                                subscribedCount: state.account.subscribedCount,
                                postCount: state.account.postCount,
                                biography: state.biography
                            )
                        )

                        await send(.accountStateChanged(.loaded(biographyChangedAccount)))
                    } else {
                        await send(.accountStateChanged(.loaded(account)))
                    }
                } else if state.biography != state.account.biography {
                    let biographyChangedAccount = try await self.service.updateBiography(
                        account: Account(
                            id: state.account.id,
                            username: state.account.username,
                            email: state.account.email,
                            picture: state.account.picture,
                            subscriberCount: state.account.subscriberCount,
                            subscribedCount: state.account.subscribedCount,
                            postCount: state.account.postCount,
                            biography: state.biography
                        )
                    )

                    await send(.accountStateChanged(.loaded(biographyChangedAccount)))
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

        case let .setBiography(biography):
            state.biography = biography
            
            if state.biography.count >= state.textMaxLength {
                state.biography = String(state.biography.prefix(state.textMaxLength))
            }

            return .none

        case .reset:
            state.pickedImage = nil
            
            return .none
        }
    }
}
