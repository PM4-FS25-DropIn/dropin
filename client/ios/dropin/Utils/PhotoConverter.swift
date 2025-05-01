//
//  PhotoConverter.swift
//  dropin
//
//  Created by Michael Voemel on 01.05.2025.
//

import Foundation
import SwiftUI
import PhotosUI

func convertPhotoSelectionToEventThumbnail(_ photos: [PhotosPickerItem]) async throws -> [EventThumbnail] {
    var eventThumbnails: [EventThumbnail] = []
    
    for photo in photos {
        guard let eventThumbnail = try await photo.loadTransferable(type: EventThumbnail.self) else {
            continue
        }
        eventThumbnails.append(eventThumbnail)
    }
    
    return eventThumbnails
}
