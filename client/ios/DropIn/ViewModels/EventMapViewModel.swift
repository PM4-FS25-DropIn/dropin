import SwiftUI
@preconcurrency import MapKit


/// View model for managing map interactions and navigation to DropIn events.
/// Handles camera state, selected events, and route calculations.
@MainActor
@Observable
final class EventMapViewModel {
    
    /// Shared location service instance used to retrieve the user's current location.
    @ObservationIgnored var locationService = LocationService.shared
    /// Reference to the shared event store containing all available events.
    @ObservationIgnored var eventStore: EventStore?
    
    /// Current visible map region, updated on camera movement.
    var visibleRegion: MKCoordinateRegion?
    
    /// The ID of the currently selected event on the map.
    var selectedEventId: Int?
    
    /// Route to the selected event, calculated using MapKit directions.
    var route: MKRoute?
    
    /// Timestamp of the last camera region update.
    var lastCameraUpdate = Date()
    
    /// Formatted estimated travel time to the selected event.
    var travelTime: String? {
        guard let route = route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    /// Calculates walking directions from the user's location to the selected event.
    /// - Parameter selectedItem: The selected map item containing the event ID.
    func getDirections(of selectedItem: MapSelection<Int>) {
        route = nil
        guard let eventStore else { return }
        if let value = selectedItem.value {
            if value < eventStore.events.count {
                let request = MKDirections.Request()
                request.transportType = .walking
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationService.lastLocation.coordinate))
                request.destination = eventStore.events[value].mapItem
                
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

