//
//  EventStatusBadge.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct EventStatusBadge: View {
    
    var status: EventStatus
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(getColor())
                .brightness(0.5)
                .shadow(color: getColor(), radius: 10)
            Spacer()
            Text(status.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(getColor())
                .brightness(0.5)
                .shadow(color: getColor(), radius: 10)
                .bold()
            Spacer()
        }
        .padding()
        .containerRelativeFrame(.horizontal, count: 10, span: 3, spacing: 0)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    private func getColor() -> Color {
        switch status {
        case .upcoming: return .teal
        case .live: return .green
        case .closing: return .red
        }
    }
}

#Preview {
    EventStatusBadge(status: .upcoming)
    EventStatusBadge(status: .live)
    EventStatusBadge(status: .closing)
}
