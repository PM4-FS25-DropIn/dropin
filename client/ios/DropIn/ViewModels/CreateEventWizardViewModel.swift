//
//  CreateEventWizardViewModel.swift
//  DropIn
//
//  Created by leo on 08.05.2025.
//

import SwiftUI
import MapKit
import PhotosUI

@MainActor
@Observable
final class CreateEventWizardViewModel {
    
    var selectedPhotos: [PhotosPickerItem]
    var pinLocation: CLLocationCoordinate2D = LocationService.shared.lastLocation.coordinate
    var event: DropInEvent
    
    init(selectedPhotos: [PhotosPickerItem]) {
        self.selectedPhotos = selectedPhotos
        let currentUserLocation = LocationService.shared.lastLocation.coordinate
        self.event = DropInEvent(title: "", description: "", start: Date(), end: Date(), slotLimit: 2, ageRestricted: false, chatEnabled: true, location: .init(type: "Point", coordinates: [currentUserLocation.longitude, currentUserLocation.latitude]))
    }
    
}
