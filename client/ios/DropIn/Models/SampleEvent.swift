import Foundation

let sampleEvent: DropInEvent = .init(id: 1, title: "Event", description: "Event Description", imagePaths: ["default.event.thumbnail"], userId: UUID(), start: .now, end: .now, slotLimit: 5, ageRestricted: true, chatEnabled: true, location: .init(type: "Point", coordinates: [0,0]))




