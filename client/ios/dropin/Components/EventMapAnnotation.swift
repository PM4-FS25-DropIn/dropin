//
//  EventMarker.swift
//  dropin
//
//  Created by leo on 16.04.2025.
//

import SwiftUI

struct EventMapAnnotation: View {
    
    var body: some View {
        Circle()
            .fill(.accent.opacity(0.5))
            .stroke(.accent.opacity(0.2), lineWidth: 10)
    }
}

#Preview {
    EventMapAnnotation()
}
