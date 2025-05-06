//
//  DropInEventForm.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI
import PhotosUI
@preconcurrency import MapKit

struct DropInEventForm: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var event: DropInEvent
    
    @Binding var selectedPhotos: [PhotosPickerItem]
    
    var isEditing: Bool
    
    var body: some View {
        Form {
            titleAndDescription
            location
            time
            participants
            PhotoSelector(selectedPhotos: $selectedPhotos, text: "Add Photos")
        }
    }
    
    private var titleAndDescription: some View {
        Section(header: Text("What's happening?")) {
            TextField("Title", text: $event.title)
            TextField("Description", text: $event.description)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.sentences)
    }
    
    private var location: some View {
        Section(header: Text("Where?")) {
            // TODO: Map search
            TextField("Latitude", value: $event.latitude, formatter: decimalFormatter)
            TextField("Longitude", value: $event.longitude, formatter: decimalFormatter)
        }
    }
    
    private var time: some View {
        Section(header: Text("When?")) {
                // Create View
                DatePicker("Start", selection: $event.start, in:
                        .now...(Calendar.current.date(byAdding: .hour, value: 24, to: .now) ?? .now),
                           displayedComponents: [.date, .hourAndMinute])
                .disabled(isEditing)
                DatePicker("End", selection: $event.end, in:
                            event.start...(Calendar.current.date(byAdding: .hour, value: 24, to: event.start) ?? event.start), displayedComponents: [.date, .hourAndMinute])
                .disabled(isEditing)
            
        }
    }
    
    private var participants: some View {
        Section(header: Text("Participants")) {
            HStack {
                Text("Max Slots: \(event.slotLimit)")
                    .frame(minWidth: 120, alignment: .leading)
                Slider(
                    value: Binding(
                        get: { Double(event.slotLimit) },
                        set: { event.slotLimit = Int($0) }
                    ),
                    in: max(2, Double(event.slotsTaken ?? 2))...100,
                    step: 1,
                    onEditingChanged: { _ in }
                )
                
            }
            Toggle(isOn: $event.ageRestricted) {
                Text("Age Restricted")
            }
        }
    }
}


#Preview {
    @Previewable @State var event = DropInEvent(title: "Title", description: "Description", imagePaths: ["default.event.thumbnail"], userId: UUID(), start: Date(), end: Date(), latitude: 0, longitude: 0, slotLimit: 4, ageRestricted: false, chatEnabled: true)
    @Previewable @State var formState: OperationState = .init()
    @Previewable @State var selectedPhotos: [PhotosPickerItem] = []
    
    DropInEventForm(event: $event, selectedPhotos: $selectedPhotos, isEditing: false)
}