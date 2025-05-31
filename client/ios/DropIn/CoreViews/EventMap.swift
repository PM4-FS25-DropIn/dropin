//
//  MapContentView.swift
//  dropin-prototype
//
//  Created by leo on 23.04.2025.
//

import SwiftUI
@preconcurrency import MapKit

struct EventMap: View {
    @Environment(EventStore.self) private var eventStore
    @Bindable var viewModel: EventMapViewModel
    
    @State private var eventFetchState: AsyncStatus = .idle
    
    @State var cameraPosition: MapCameraPosition = .userLocation(fallback: .region(.bellevueRegion))

    @State private var showEventDetailSheet = false
    @State private var showCreateViewSheet = false
    
    @State private var selectedItem: MapSelection<Int>?
    @State private var pinLocation: CLLocationCoordinate2D?
    
    var body: some View {
        map
            .onAppear {
                viewModel.eventStore = eventStore
                initialEventSetup()
                cameraPosition = .userLocation(fallback: .region(.bellevueRegion))
            }
    }
    
    var map: some View {
        MapReader { proxy in
            Map(position: $cameraPosition, selection: $selectedItem) {
                UserAnnotation()
                if let pinLocation {
                    Marker("DropIn", systemImage: "drop", coordinate: pinLocation)
                        .tint(.indigo)
                }
                ForEach(eventStore.events.indices, id: \.self) { index in
                    let event = eventStore.events[index]
                    Marker(event.title, systemImage: getDropIcon(event: event), coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
                        .tag(MapSelection(index))
                        .tint(getEventStatusColor(event.status))
                }
                
                if let route = viewModel.route {
                    if route.distance < 1500 {
                        MapPolyline(route)
                            .stroke(.accent, lineWidth: 5)
                    }
                }
            }
            .sheet(isPresented: $showEventDetailSheet) {
                dropInDetailSheet
            }
            .sheet(isPresented: $showCreateViewSheet) {
                pinLocation = nil
            } content: {
                CreateEventWizard(pinLocation: pinLocation)
            }
            .onChange(of: selectedItem) {
                guard let selectedItem else { return }
                if let _ = selectedItem.value {
                    showEventDetailSheet = true
                    getDirectionsOfSelectedItem()
                }
            }
            .mapFeatureSelectionAccessory(.callout)
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapPitchToggle()
            }
            .onMapCameraChange { context in
                onMapCameraChangeUpdate(context: context)
            }
            .overlay(alignment: .topLeading) {
                fetchIndicator
                    .padding(.horizontal)
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCoordinates(latitude: viewModel.locationService.lastLocation.coordinate.latitude,
                                           longitude: viewModel.locationService.lastLocation.coordinate.longitude))
                }
                .font(.caption)
                .padding(8)
                .background(.ultraThinMaterial)
                .foregroundStyle(.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding()
            }
            .gesture(MyLongPressGesture { position in
                pinLocation = proxy.convert(position, from: .global)
                if (!showEventDetailSheet) {
                    showCreateViewSheet = true
                }
            })
        }
    }
    
    var dropInDetailSheet: some View {
        Group {
            if let value = selectedItem?.value {
                if value < eventStore.events.count {
                    MapEventItemDetailSheet(viewModel: viewModel, event: eventStore.events[value], travelTime: viewModel.travelTime)
                }
            } else {
                ContentUnavailableView {
                    Label("No Event", systemImage: "texclamationmark.triangle")
                } description: {
                    Text("Event not found.")
                }
            }
        }
        .presentationDetents([.fraction(0.25), .medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.25)))
        .presentationContentInteraction(.resizes)
    }
    
    
    /// Indicate if it's currently updating the map (fetching new events).
    var fetchIndicator: some View {
        Text(eventFetchState.isRunning ? "Searching nearby events…" : "Events up to date")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(6)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    /// If camera is currently following user, only fetch new updates every 5 seconds. Otherwise fetch,
    /// whenever the camera position gets changed by the user.
    private func onMapCameraChangeUpdate(context: MapCameraUpdateContext) {
        let now = Date()
        if cameraPosition.followsUserLocation && now.timeIntervalSince(viewModel.lastCameraUpdate) > 5 {
            viewModel.lastCameraUpdate = now
            viewModel.visibleRegion = context.region
            updateMapEvents()
        } else if cameraPosition.positionedByUser {
            viewModel.visibleRegion = context.region
            updateMapEvents()
        }
    }
    
    /// Fetch new events.
    private func updateMapEvents() {
        Task {
            eventFetchState = .running
            do {
                try await eventStore.fetchEventsInCameraRegion(latitude: viewModel.visibleRegion?.center.latitude ?? 0, longitude: viewModel.visibleRegion?.center.longitude ?? 0, latitudeDelta: viewModel.visibleRegion?.span.latitudeDelta ?? 0.25, longitudeDelta: viewModel.visibleRegion?.span.longitudeDelta ?? 0.25)
                try await Task.sleep(for: .seconds(0.5))
                print("Fetching new events")
                eventFetchState = .success
            } catch {
                print("Couldn't fetch events")
                eventFetchState = .failure(error)
            }
        }
    }
    
    private func initialEventSetup() {
        Task {
            try await eventStore.clearEvents()
            eventFetchState = .running
            do {
                try await eventStore.fetchEventsInCameraRegion(latitude: viewModel.visibleRegion?.center.latitude ?? 0, longitude: viewModel.visibleRegion?.center.longitude ?? 0, latitudeDelta: viewModel.visibleRegion?.span.latitudeDelta ?? 0.25, longitudeDelta: viewModel.visibleRegion?.span.longitudeDelta ?? 0.25)
                try await Task.sleep(for: .seconds(0.5))
                print("Fetching new events")
                eventFetchState = .success
            } catch {
                print("Couldn't fetch events")
                eventFetchState = .failure(error)
            }
        }
    }
    
    func getDropIcon(event: DropInEvent) -> String {
        guard let eventId = event.id else { return "drop" }
        return eventStore.getAttendanceStatus(of: eventId) == .joined ? "drop.fill" : "drop"
    }
    
    /// Getting directions to a selected item.
    private func getDirectionsOfSelectedItem() {
        guard let selectedItem else {
            print("No item selected")
            return
        }
        viewModel.getDirections(of: selectedItem)
    }
    
}

#Preview {
    EventMap(viewModel: EventMapViewModel())
        .environment(EventStore())
}
