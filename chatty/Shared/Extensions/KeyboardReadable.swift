//
//  KeyboardReadable.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 19.08.23.
//

import UIKit
import Combine

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter
                .default
                .publisher(
                    for: UIResponder.keyboardDidShowNotification
                )
                .map { _ in true },
            NotificationCenter
                .default
                .publisher(
                    for: UIResponder.keyboardDidHideNotification
                )
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
