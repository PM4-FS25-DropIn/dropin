import SwiftUI
@preconcurrency import MapKit


@MainActor
@Observable
final class EventMapViewModel {
    
    @ObservationIgnored var locationService = LocationService.shared
    @ObservationIgnored var eventStore: EventStore?
    
    var visibleRegion: MKCoordinateRegion?
    
    var selectedEventId: Int?
    
    var route: MKRoute?
    
    var lastCameraUpdate = Date()
    
    var travelTime: String? {
        guard let route = route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    /// Get Directions to an event
    func getDirections(of selectedItem: MapSelection<Int>) {
        route = nil
        guard let eventStore else { return }
        if let value = selectedItem.value {
            if value < eventStore.mapEvents.count {
                let request = MKDirections.Request()
                request.transportType = .walking
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationService.lastLocation.coordinate))
                request.destination = eventStore.mapEvents[value].mapItem
                
                Task {
                    let directions = MKDirections(request: request)
                    let response = try? await directions.calculate()
                    route = response?.routes.first
                }
            }
        } else {
            print("Couldn't get directions")
        }
    }
    
}

