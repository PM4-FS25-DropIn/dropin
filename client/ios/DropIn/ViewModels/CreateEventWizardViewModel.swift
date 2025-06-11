//
//  CreateEventWizardViewModel.swift
//  DropIn
//
//  Created by leo on 08.05.2025.
//

import SwiftUI
import MapKit
import PhotosUI

/// View model for managing the state and data required to create a new DropIn event.
/// Handles selected photos, user location, and default event setup.
@MainActor
@Observable
final class CreateEventWizardViewModel {
    
    /// The photos selected by the user to associate with the event.
    var selectedPhotos: [PhotosPickerItem]
    /// The location pinned for the new event, defaulting to the user's last known location.
    var pinLocation: CLLocationCoordinate2D = LocationService.shared.lastLocation.coordinate
    /// The event being created and configured by the user.
    var event: DropInEvent
    
    /// Initializes the view model with selected photos and a default event at the user's location.
    /// - Parameter selectedPhotos: The photos selected by the user.
    init(selectedPhotos: [PhotosPickerItem]) {
        self.selectedPhotos = selectedPhotos
        let currentUserLocation = LocationService.shared.lastLocation.coordinate
        self.event = DropInEvent(title: "", description: "", start: Date(), end: Date(), slotLimit: 2, ageRestricted: false, chatEnabled: true, location: .init(type: "Point", coordinates: [currentUserLocation.longitude, currentUserLocation.latitude]))
    }
    
}
