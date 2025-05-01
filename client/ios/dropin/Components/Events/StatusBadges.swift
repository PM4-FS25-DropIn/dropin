//
//  EventStatusBadge.swift
//  dropin
//
//  Created on 02.04.2025.
//

import SwiftUI


struct EventCardStatusBadge: View {
    
    var status: EventStatus
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(getEventStatusColor(status))
                .brightness(0.5)
                .shadow(color: getEventStatusColor(status), radius: 10)
            Spacer()
            Text(status.rawValue)
                .font(.caption)
                .foregroundStyle(getEventStatusColor(status))
                .brightness(0.5)
                .shadow(color: getEventStatusColor(status), radius: 10)
                .bold()
            Spacer()
        }
        .padding()
        .containerRelativeFrame(.horizontal, count: 10, span: 3, spacing: 0)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
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
            .background(getEventStatusColor(status), in: RoundedRectangle(cornerRadius: 6))
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
