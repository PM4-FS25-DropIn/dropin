//
//  FormUtility.swift
//  dropin
//
//  Created by Michael Voemel on 01.05.2025.
//

import Foundation

/// A simple formatter for decimal numbers.
var decimalFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 8
    return formatter
}
