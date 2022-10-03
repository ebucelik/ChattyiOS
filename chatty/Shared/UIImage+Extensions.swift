//
//  UIImage+Extensions.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 03.10.22.
//

import UIKit

public extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}
