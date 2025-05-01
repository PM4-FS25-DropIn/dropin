//
//  EventCreatedView.swift
//  dropin
//
//  Created by Michael Voemel on 15.04.2025.
//


import SwiftUI

// TODO: connect to rest of the application (in the tab bar component)
struct EventCreateView: View {
    @State private var event = DropInEvent(
        id: 1,
        title: "",
        description: "",
        start: Date(),
        end: Calendar.current.date(byAdding: .minute, value: 90, to: Date()) ?? Date(),
        latitude: 47.3769, // Zurich
        longitude: 8.5417, // Zurich
        maxSlots: 1,
        takenSlots: 0,
        visibility: .public,
        ageRestricted: false,
        chatEnabled: true,
        status: .upcoming
    )
    
    var body: some View {
        DropInEventFormView(event: $event) {
            // TODO: implement creation mechanism
            print("Creating event: \(event.title)")
        }
    }
}

#Preview {
    EventCreateView()
}
