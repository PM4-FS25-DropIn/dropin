//
//  DummyEvent.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import Foundation

let dummyEvent = DropInEvent(id: 1, createdAt: Date(), title: "Event", description: "Some event description", imagePaths: ["default.event.thumbnail"], userId: UUID(), start: Date(), end: Date(), latitude: 20, longitude: 29, maxSlots: 20, takenSlots: 5, visibility: .public, ageRestricted: false, chatEnabled: true, status: .upcoming)
