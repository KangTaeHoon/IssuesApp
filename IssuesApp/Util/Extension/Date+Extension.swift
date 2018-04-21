//
//  Date+Extension.swift
//  Issues.rx
//
//  Created by leonard on 2018. 4. 11..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import Foundation

extension Date {
    func string(dateFormat: String, locale: String = "en-US") -> String {
        let format = DateFormatter()
        format.dateFormat = dateFormat
        format.locale = Locale(identifier: locale)
        return format.string(from: self)
    }
}
