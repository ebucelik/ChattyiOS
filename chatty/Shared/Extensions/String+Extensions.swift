//
//  String+Extensions.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 03.10.22.
//

import UIKit

public extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }

        return UIImage(data: imageData)
    }
}
