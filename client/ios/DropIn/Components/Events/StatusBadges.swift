//
//  EventStatusBadge.swift
//  dropin
//
//  Created on 02.04.2025.
//

import SwiftUI

/// Shows a status badge for an event.
struct EventCardStatusBadge: View {
    
    var status: EventStatus
    
    var body: some View {
        HStack {
            Text(status.rawValue)
                .font(.caption)
                .foregroundStyle(getEventStatusColor(status))
                .brightness(0.1)
                .shadow(color: getEventStatusColor(status), radius: 10)
                .bold()
        }
        .padding(.vertical, 5)
        .containerRelativeFrame(.horizontal, count: 8, span: 2, spacing: 0)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 30))
    }
}

struct EventStatusBadge: View {
    var status: EventStatus
    
    var body: some View {
        Text(status.rawValue)
            .frame(width: 75, height: 20)
            .foregroundStyle(.white)
            .font(.footnote)
            .bold()
            .background(getEventStatusColor(status), in: RoundedRectangle(cornerRadius: 30))
    }
}

#Preview {
    EventStatusBadge(status: .upcoming)
    EventStatusBadge(status: .live)
    EventStatusBadge(status: .closing)
}

#Preview {
    EventCardStatusBadge(status: .upcoming)
    EventCardStatusBadge(status: .live)
    EventCardStatusBadge(status: .closing)
}
