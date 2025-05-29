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
    case .closed: return .gray
    }
}


func getEventStatusColorGradient(_ status: EventStatus) -> LinearGradient {
    switch status {
    case .upcoming: return LinearGradient(gradient: Gradient(colors: [.lightCyan, .pacificCyan]), startPoint: .topLeading,
                                          endPoint: .bottomTrailing)
    case .live: return LinearGradient(gradient: Gradient(colors: [.green, .green.mix(with: .blue, by: 0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case .closing: return LinearGradient(gradient: Gradient(colors: [.red, .red.mix(with: .orange, by: 0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case .closed: return LinearGradient(gradient: Gradient(colors: [.gray, .black]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
