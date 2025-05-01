//
//  EventEditView.swift
//  dropin
//
//  Created by Michael Voemel on 15.04.2025.
//

import SwiftUI

// TODO: connect to rest of the application (in the tab bar component)
struct EventEditView: View {
    @State private var event: DropInEvent
    
    init(existingEvent: DropInEvent) {
        _event = State(initialValue: existingEvent)
    }
    
    var body: some View {
        DropInEventFormView(event: $event) {
            // TODO: implement updating mechanism
            print("Updating event: \(event.title)")
        }
    }
}

#Preview {
    EventEditView(existingEvent: dummyEvent)
}
