//
//  MapView.swift
//  dropin
//
//  Created by leo on 16.04.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var mapSelection: MKMapItem?
    
    var body: some View {
        Map(selection: $mapSelection) {
            ForEach(eventLocations, id: \.self) { event in
                Marker("Event", systemImage: "drop.fill", coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
                    .tint(.accent)
                    .tag(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))))
            }
        }
    }
}

private struct EventDetail: Identifiable, Hashable {
    let id = UUID()
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
}


private let eventLocations: [EventDetail] = [
    EventDetail(latitude: 47.3769, longitude: 8.5417), // Zürich HB
    EventDetail(latitude: 47.3780, longitude: 8.5456), // Bahnhofquai
    EventDetail(latitude: 47.3711, longitude: 8.5383), // Paradeplatz
    EventDetail(latitude: 47.3689, longitude: 8.5392), // Bahnhofstrasse
    EventDetail(latitude: 47.3702, longitude: 8.5476), // Sihlquai
    EventDetail(latitude: 47.3738, longitude: 8.5485), // Central
    EventDetail(latitude: 47.3772, longitude: 8.5280), // Hardplatz
    EventDetail(latitude: 47.3925, longitude: 8.5377), // Milchbuck
    EventDetail(latitude: 47.3790, longitude: 8.5612), // Zürichhorn
    EventDetail(latitude: 47.3691, longitude: 8.5450), // Stauffacher
    EventDetail(latitude: 47.3680, longitude: 8.5213), // Albisrieden
    EventDetail(latitude: 47.3784, longitude: 8.5032), // Altstetten
    EventDetail(latitude: 47.3941, longitude: 8.4827), // Höngg
    EventDetail(latitude: 47.3842, longitude: 8.5478), // ETH Zürich
    EventDetail(latitude: 47.3656, longitude: 8.5460), // Kanzlei
    EventDetail(latitude: 47.3755, longitude: 8.5512), // Kronenstrasse
    EventDetail(latitude: 47.3766, longitude: 8.5551), // Rigiplatz
    EventDetail(latitude: 47.3802, longitude: 8.5624), // Chinagarten
    EventDetail(latitude: 47.3900, longitude: 8.5155), // Wipkingen
    EventDetail(latitude: 47.3830, longitude: 8.5061), // Hardturm
    EventDetail(latitude: 47.3648, longitude: 8.5284), // Lochergut
    EventDetail(latitude: 47.3779, longitude: 8.5389), // Universität Zürich
    EventDetail(latitude: 47.3862, longitude: 8.5174), // Käferberg
    EventDetail(latitude: 47.3622, longitude: 8.5488), // Schanzengraben
    EventDetail(latitude: 47.3666, longitude: 8.5511), // Selnau
]


#Preview {
    MapView()
}
