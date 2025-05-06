//
//  AllEventsList.swift
//  dropin
//
//  Created on 01/05/2025.
//


import SwiftUI


/// Displays a list of joined events of user (excluding the ones created by user!)
struct AllEventsList: View {
    @Environment(EventStore.self) private var eventStore
    
    @State private var onLeaveSwipeTaskStatus: AsyncStatus = .idle
    @State private var showAlert = false
    
    var body: some View {
        List {
            ForEach(eventStore.joinedEvents) { event in
                EventRowItem(event: event)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onLeaveSwipeAction(event)
                        } label: {
                            Label("Drop Out", systemImage: "figure.walk")
                        }
                        .border(.black, width: 5)
                    }
            }
        }
        .scrollContentBackground(.hidden)
        .alert("Error", isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            Text(onLeaveSwipeTaskStatus.error)
        }
    }
    
    private func onLeaveSwipeAction(_ event: DropInEvent) {
        Task {
            onLeaveSwipeTaskStatus = .running
            
            do {
                try await eventStore.leaveEvent(event)
                onLeaveSwipeTaskStatus = .success
            } catch {
                onLeaveSwipeTaskStatus = .failure(error)
                showAlert = true
            }
        }
    }
    
}

#Preview {
    AllEventsList()
        .environment(EventStore())
}
