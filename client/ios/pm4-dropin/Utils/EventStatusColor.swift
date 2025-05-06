//
//  EventStatusColor.swift
//  dropin
//
//  Created by Michael Voemel on 01.05.2025.
//

import SwiftUI


func getEventStatusColor(_ status: EventStatus) -> Color {
    switch status {
    case .upcoming: return .teal
    case .live: return .green
    case .closing: return .red
    }
}
