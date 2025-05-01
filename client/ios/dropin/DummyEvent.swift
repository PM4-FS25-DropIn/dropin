//
//  DummyEvent.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import Foundation

let dummyEvent = DropInEvent(id: 1, createdAt: Date(), title: "Event", description: "Some event description", imagePaths: ["default.event.thumbnail"], userId: UUID(), start: Date(), end: Date(),  latitude: 47.3769, longitude: 8.5417, slotLimit: 20, slotsTaken: 5, ageRestricted: false, chatEnabled: true)
