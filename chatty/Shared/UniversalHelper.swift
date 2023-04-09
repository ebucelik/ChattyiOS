//
//  UniversalHelper.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 09.04.23.
//

import UIKit

class UniversalHelper {
    static func resignFirstResponder() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
