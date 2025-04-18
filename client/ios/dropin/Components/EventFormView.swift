//
//  EventFormView.swift
//  dropin
//
//  Created by Michael Voemel on 15.04.2025.
//

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
}

struct DropInEventFormView: View {
    @Binding var event: DropInEvent
    @FocusState private var focusedField: Field?
    @State private var region: MKCoordinateRegion
    @State private var locationText: String = ""
    
    var onSave: () -> Void
    
    enum Field: Hashable {
        case title, description, location
    }
    
    init(event: Binding<DropInEvent>, onSave: @escaping () -> Void) {
        self._event = event
        self.onSave = onSave
        
        // Defaults to Zurich
        let coordinate = CLLocationCoordinate2D(
            latitude: event.wrappedValue.latitude != 0 ? event.wrappedValue.latitude : 47.3769,
            longitude: event.wrappedValue.longitude != 0 ? event.wrappedValue.longitude : 8.5417
        )
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        
        if event.wrappedValue.latitude != 0 && event.wrappedValue.longitude != 0 {
            // TODO: implement reverseGeocodeLocation function to get location name from coord
            self._locationText = State(initialValue: "Location set")
        } else {
            self._locationText = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $event.title)
                        .font(.title)
                        .focused($focusedField, equals: .title)
                    
                    TextField("Description", text: $event.description)
                        .focused($focusedField, equals: .description)
                } header: {
                    Text("What's happening?")
                        .font(.headline)
                        .foregroundColor(.black)
                        .textCase(nil)
                }
                
                Section {
                    HStack {
                        Text("Start")
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        DatePicker("", selection: $event.start, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .onChange(of: event.start) { oldValue, newValue in
                                if newValue >= event.end {
                                    event.end = Calendar.current.date(
                                        byAdding: .minute,
                                        value: 90,
                                        to: newValue
                                    ) ?? event.end
                                }
                            }
                    }
                    
                    HStack {
                        Text("End")
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        DatePicker("", selection: $event.end, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .onChange(of: event.end) { oldValue, newValue in
                                if newValue <= event.start {
                                    event.end = Calendar.current.date(
                                        byAdding: .minute,
                                        value: 90,
                                        to: event.start
                                    ) ?? event.end
                                }
                            }
                    }
                } header: {
                    Text("When?")
                        .font(.headline)
                        .foregroundColor(.black)
                        .textCase(nil)
                }
                
                Section {
                    VStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search Map", text: $locationText)
                                .focused($focusedField, equals: .location)
                                .onChange(of: locationText) { oldValue, newValue in
                                    if !newValue.isEmpty {
                                        updateMapRegion(for: newValue)
                                    }
                                }
                            
                            Image(systemName: "mic")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(10)
                        
                        Map(initialPosition: .region(region)) {
                            Marker("Event Location", coordinate: region.center)
                                .tint(.red)
                        }
                        .frame(height: 150)
                        .cornerRadius(10)
                        .padding(.top, 8)
                        // TODO: either properly implement or discard
                        //.onTapGesture {
                        //    event.latitude = region.center.latitude
                        //    event.longitude = region.center.longitude
                        //    reverseGeocodeLocation()
                        //}
                        // TODO: manual update of coord, either properly implement or discard
                        //Button("Set Location") {
                        //    event.latitude = region.center.latitude
                        //    event.longitude = region.center.longitude
                        //    reverseGeocodeLocation()
                        //}
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                } header: {
                    Text("Where?")
                        .font(.headline)
                        .foregroundColor(.black)
                        .textCase(nil)
                }
                
                Section {
                    HStack {
                        Text("Slots")
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        Stepper(value: $event.maxSlots, in: 1...100) {
                            Text("\(event.maxSlots)")
                                .frame(width: 40)
                        }
                    }
                    
                    Toggle("Age Restriction", isOn: $event.ageRestricted)
                    
                    Toggle("Chat Enabled", isOn: $event.chatEnabled)
                    
                    Picker("Visibility", selection: $event.visibility) {
                        Text("Public").tag(EventVisibility.public)
                        Text("Friends").tag(EventVisibility.friends)
                        Text("Invite").tag(EventVisibility.invite)
                    }
                } header: {
                    Text("Who can join?")
                        .font(.headline)
                        .foregroundColor(.black)
                        .textCase(nil)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        // TODO: implement back behaviour in parent component
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .foregroundColor(.blue)
                    .disabled(event.title.isEmpty)
                }
                
            }
            .navigationTitle("Save Event")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func updateMapRegion(for location: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = location
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, error == nil else { return }
            
            if let firstResult = response.mapItems.first {
                region = MKCoordinateRegion(
                    center: firstResult.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                event.latitude = firstResult.placemark.coordinate.latitude
                event.longitude = firstResult.placemark.coordinate.longitude
            }
        }
    }
    
    private func reverseGeocodeLocation() {
        // TODO: implement
    }
}
