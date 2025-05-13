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
        if now < start.addingTimeInterval(-2 * 60 * 60) {
            return .upcoming
        } else if now >= start && now < end.addingTimeInterval(-10 * 60) {
            return .live
        } else if now >= end.addingTimeInterval(-10 * 60) && now < end {
            return .closing
        } else {
            return .upcoming
        }
    }
}


