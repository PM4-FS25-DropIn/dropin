import Foundation
import MapKit

extension DropInEvent {
    var mapItem: MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        return MKMapItem(placemark: placemark)
    }
    
    var status: EventStatus {
        let now = Date()
        let totalDuration = end.timeIntervalSince(start)
        let closingThreshold = end.addingTimeInterval(-totalDuration * 0.1)

        if now < start {
            return .upcoming
        } else if now >= start && now < closingThreshold {
            return .live
        } else if now >= closingThreshold && now < end {
            return .closing
        } else {
            return .closed
        }
    }
}


