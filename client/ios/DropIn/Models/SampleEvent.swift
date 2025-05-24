import Foundation

let sampleEvent: DropInEvent = .init(id: 1, title: "Event", description: "Event Description", imagePaths: ["https://canto-wp-media.s3.amazonaws.com/app/uploads/2019/08/19194138/image-url-3.jpg"], userId: UUID(), start: .now, end: .now, slotLimit: 5, ageRestricted: true, chatEnabled: true, location: .init(type: "Point", coordinates: [0,0]))



