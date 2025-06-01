//
//  MiniMap.swift
//  DropIn
//
//  Created by leo on 24.05.2025.
//

import SwiftUI
import MapKit

/// A small map displaying a single event.
struct MiniMap: View {
    
    var event: DropInEvent
    
    var body: some View {
        VStack {
            Text("Location")
                .font(.title2)
                .bold()
            Text(formatCoordinates(latitude: event.latitude, longitude: event.longitude))
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)
            Map(initialPosition: .region(MKCoordinateRegion(center: .init(latitude: event.latitude, longitude: event.longitude), span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001)))) {
                Marker("DropIn", systemImage: "drop", coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
                    .tint(.indigo)
            }
            .disabled(true)
            .containerRelativeFrame(.vertical, count: 12, span: 4, spacing: 0)
            .mapControlVisibility(.hidden)
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}

#Preview {
    MiniMap(event: sampleEvent)
}
