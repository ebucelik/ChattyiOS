//
//  Int+Extensions.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 11.02.23.
//

import Foundation

extension Double {
    var toStringDate: String {
        let date = Date(timeIntervalSinceReferenceDate: self)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.autoupdatingCurrent
        dateFormatter.dateFormat = "d. MMM yyyy"

        return dateFormatter.string(from: date)
    }

    var toStringTime: String {
        let date = Date(timeIntervalSinceReferenceDate: self)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.autoupdatingCurrent
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: date)
    }
}
