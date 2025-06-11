//
//  OpenInMapsButton.swift
//  DropIn
//
//  Created by leo on 24.05.2025.
//

import SwiftUI
import MapKit

/// A button to open an event in Apple Maps.
struct OpenInMapsButton: View {
    
    var event: DropInEvent
    
    var body: some View {
        Button {
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
                latitude: event.latitude, longitude: event.longitude)))

            destination.name = event.title

            MKMapItem.openMaps(
                with: [destination],
                launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            )
        } label: {
            Label("Open in Maps", systemImage: "map")
                .font(.subheadline)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

#Preview {
    OpenInMapsButton(event: sampleEvent)
}
