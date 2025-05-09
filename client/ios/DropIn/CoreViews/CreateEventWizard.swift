//
//  CreateEventWizard.swift
//  DropIn
//
//  Created by leo on 08.05.2025.
//

import SwiftUI
import MapKit
import PhotosUI


struct CreateEventWizard: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EventStore.self) private var eventStore
    
    @State private var vm = CreateEventWizardViewModel(selectedPhotos: [])
    
    @State private var launchState: AsyncStatus = .idle
    
    init(pinLocation: CLLocationCoordinate2D? = nil) {
        if let pinLocation {
            vm.pinLocation = pinLocation
            vm.event.latitude = pinLocation.latitude
            vm.event.longitude = pinLocation.longitude
        }
    }
    
    var body: some View {
        TabView {
            Tab {
                Image(systemName: "hand.wave.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                titleAndSubtitleTab
            }
            Tab {
                Image(systemName: "location.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                locationTab
            }
            Tab {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    .font(.title)
                    .foregroundStyle(.accent)
                timeTab
            }
            Tab {
                Image(systemName: "person.3")
                    .font(.title)
                    .foregroundStyle(.accent)
                participantsTab
            }
            Tab {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.accent)
                photosTab
            }
            Tab {
                launchTab
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    // MARK: - Title and Subtitle Tab
    
    private var titleAndSubtitleTab: some View {
        VStack(alignment: .center, spacing: 40) {
            header(title: "What's going on?", description: "Give your DropIn a title and short description so others know what to expect.")
            TextField("Title", text: $vm.event.title)
                .roundedTextFieldStyle(strokeColor: .secondary)
            TextEditor(text: $vm.event.description)
                .roundedTextFieldStyle(strokeColor: .secondary)
                .containerRelativeFrame(.vertical, count: 10, span: 2, spacing: 0)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.sentences)
        .padding()
    }
    
    // MARK: - Location Tab
    
    private var locationTab: some View {
        VStack(alignment: .center, spacing: 25) {
            header(title: "Where's the DropIn?", description: "Pick the spot where your DropIn will take place. This will be later displayed on the map.")
            MapReader { proxy in
                Map(initialPosition: .region(MKCoordinateRegion(center: vm.pinLocation, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
                    Marker("DropIn", systemImage: "drop", coordinate: vm.pinLocation)
                        .tint(.indigo)
                }
                .mapControlVisibility(.hidden)
                .containerRelativeFrame(.vertical, count: 10, span: 5, spacing: 0)
                .gesture(MyLongPressGesture { position in
                    if let loc = proxy.convert(position, from: .global) {
                        vm.pinLocation = loc
                        vm.event.latitude = loc.latitude
                        vm.event.longitude = loc.longitude
                    }
                })
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Text(formatCoordinates(latitude: vm.pinLocation.latitude, longitude: vm.pinLocation.longitude))
        }
        .padding()
    }
    
    // MARK: Start-End Time Tab
    
    private var timeTab: some View {
        VStack(alignment: .center, spacing: 40) {
            header(title: "When is it happening?", description: "Set the start and end time.")
            DatePicker("Start", selection: $vm.event.start, in:
                    .now...(Calendar.current.date(byAdding: .hour, value: 24, to: .now) ?? .now),
                       displayedComponents: [.date, .hourAndMinute])
            DatePicker("End", selection: $vm.event.end, in:
                        vm.event.start...(Calendar.current.date(byAdding: .hour, value: 24, to: vm.event.start) ?? vm.event.start), displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
    }
    
    // MARK: Participants Tab
    
    private var participantsTab: some View {
        VStack(alignment: .center, spacing: 40) {
            header(title: "Who can join?", description: "Limit the number of participants and set age restrictions if needed.")
            Toggle(isOn: $vm.event.ageRestricted) {
                Text("Age Restricted")
            }
            .tint(.accent)
            .padding()
            Text("Available Slots")
                .font(.title3)
                .bold()
                .foregroundStyle(.primary)
            Picker("Slot limit", selection: $vm.event.slotLimit) {
               ForEach(Array(stride(from: 2, to: 100, by: 1)), id: \.self) { index in
                  Text("\(index)")
                     .tag(index)
                  }
            }
            .pickerStyle(.wheel)
            
           
        }
        .padding()
    }
    
    // MARK: Photos Tab
    
    private var photosTab: some View {
        VStack(alignment: .center, spacing: 40) {
            header(title: "Show it off!", description: "Upload some thumbnails to make your DropIn stand out!")
            PhotoSelector(selectedPhotos: $vm.selectedPhotos, text: "Add")
        }
        .padding()
    }
    
    // MARK: Launch Tab
    
    private var launchTab: some View {
        VStack(alignment: .center, spacing: 30) {
            switch launchState {
            case .idle:
                readyToLaunch
            case .running:
                launchingView
            case .success:
                launchSuccessfullView
            case .failure:
                launchFailedView
            }
        }
        .multilineTextAlignment(.center)
        .frame(width: 320, height: 320)
        .padding()
    }
    
    private func header(title: String, description: String) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title)
                .foregroundStyle(.primary)
                .bold()
            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: Launching View
    
    private var launchingView: some View {
        Group {
            Text("Launching...")
                .font(.title)
                .foregroundStyle(.primary)
                .bold()
                .padding()
            ProgressView()
        }
    }
    
    // MARK: Ready to Launch View
    
    private var readyToLaunch: some View {
        Group {
            Image(systemName: "hand.thumbsup.fill")
                .font(.title)
                .foregroundStyle(.accent)
            VStack(spacing: 10) {
                Text("Ready to Launch?")
                    .font(.title)
                    .foregroundStyle(.primary)
                    .bold()
                Text("Review your details before launching your event. You won't be able to edit this information once it's launched.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Button("Launch") {
                onLaunchButtonTapped()
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 15))
            .bold()
            .controlSize(.large)
        }
    }
    
    // MARK: Failed View
    
    private var launchFailedView: some View {
        Group {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundStyle(.red)
            VStack(spacing: 10) {
                Text("Something went wrong")
                    .font(.title2)
                    .bold()
                Text("We couldn't complete your request. Please try again.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: Success View
    
    private var launchSuccessfullView: some View {
        Group {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(.green)
            VStack(spacing: 10) {
                Text("You're all set!")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .bold()
                Text("This window will close shortly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: Launch Function
    
    private func onLaunchButtonTapped() {
        Task {
            launchState = .running
            
            do {
                try await eventStore.createEvent(vm.event, photos: vm.selectedPhotos)
                launchState = .success
                try await Task.sleep(for: .seconds(2))
                dismiss()
            } catch {
                launchState = .failure(error)
            }
        }
    }
}


#Preview {
    CreateEventWizard()
        .environment(EventStore())
}
