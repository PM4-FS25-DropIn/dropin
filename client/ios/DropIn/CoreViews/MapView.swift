//
//  MapView.swift
//  dropin
//
//  Created by leo on 16.04.2025.
//

import SwiftUI
import MapKit

/// The map view of the app.
struct MapView: View {
    
    @State private var eventMapViewModel = EventMapViewModel()
    
    var body: some View {
        EventMap(viewModel: eventMapViewModel)
    }
    
}

extension MKCoordinateRegion {
    static let bellevueRegion = MKCoordinateRegion(center: .bellevue, span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02))
}

extension CLLocationCoordinate2D {
    static let bellevue = CLLocationCoordinate2D(latitude: 47.367194, longitude: 8.544816)
}

#Preview {
    MapView()
        .environment(EventStore())
}
