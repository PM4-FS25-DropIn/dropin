//
//  FormUtility.swift
//  dropin
//
//  Created by Michael Voemel on 01.05.2025.
//

import Foundation


func isTextTooShort(_ text: String...) -> Bool {
    for t in text {
        if t.trimmingCharacters(in: .whitespaces).count < 3 {
            return true
        }
    }
    return false
}

var decimalFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 8
    return formatter
}
