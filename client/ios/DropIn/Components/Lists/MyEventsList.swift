//
//  MyEventsList.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI

/// Displays a list of events created by the user.
struct MyEventsList: View {
    @Environment(EventStore.self) private var eventStore
    @Environment(AuthService.self) private var authService
    
    @State private var events: [DropInEvent] = []
    @State private var onDeleteTaskStatus: AsyncStatus = .idle
    @State private var showEventEditView = false
    @State private var showAlert = false
    
    var body: some View {
        List {
            ForEach(eventStore.joinedEvents.filter { $0.userId == authService.userId }) { event in
                EventRowItem(event: event, isHost: true)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onDeleteSwipeAction(event)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .border(.black, width: 5)
                    }
            }
        }
        .scrollContentBackground(.hidden)
        .alert("Error", isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            Text(onDeleteTaskStatus.error)
        }
    }
    
    private func onDeleteSwipeAction(_ event: DropInEvent) {
        Task {
            onDeleteTaskStatus = .running
            
            do {
                try await eventStore.deleteEvent(event)
                onDeleteTaskStatus = .success
            } catch {
                onDeleteTaskStatus = .failure(error)
                showAlert = true
            }
        }
    }
    
}

#Preview {
    MyEventsList()
        .environment(EventStore())
        .environment(AuthService())
}
