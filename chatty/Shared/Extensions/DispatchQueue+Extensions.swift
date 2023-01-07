//
//  DispatchQueue+Extensions.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 07.01.23.
//

import Foundation
import ComposableArchitecture

extension DispatchQueue: DependencyKey {
    public static let liveValue = DispatchQueue.main
    public static let testValue = DispatchQueue.main
    public static let previewValue = DispatchQueue.main
}
