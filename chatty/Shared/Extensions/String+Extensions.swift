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

    func localize(defaultLanguage: String = "en", comment: String = "") -> String {
        let value = NSLocalizedString(self, comment: comment)

        if value != self || NSLocale.preferredLanguages.first == defaultLanguage {
            return value
        }

        guard let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return value }

        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
