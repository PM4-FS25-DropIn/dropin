//
//  EventCard.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct EventCard: View {
    @State private var username = ""
    @State private var isShowingSheet = false
    
    let event: DropInEvent
    
    var body: some View {
        VStack(alignment: .leading) {
            eventImageCarousel
            VStack(alignment: .leading, spacing: 40) {
                eventCardBody
                buttonGroup
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .onTapGesture {
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            EventDetailView(event: event)
        }
    }
    
    private var eventImageCarousel: some View {
        TabView {
            ForEach(event.imagePaths!.indices, id: \.self) { index in
                Image(event.imagePaths![index])
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
        }
        .tabViewStyle(.page)
        .containerRelativeFrame(.vertical, count: 12, span: 5, spacing: 0)
        .overlay {
            EventStatusBadge(status: event.status)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
            Image(systemName: "location.fill")
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(.lightCyan))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(12)
        }
    }
    
    private var eventCardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(event.title)
                .font(.headline)
            
            Text(event.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Label(username, systemImage: "person.fill")
                Label("\(event.takenSlots)/\(event.maxSlots) Slots", systemImage: "person.3.fill")
            }
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.top, 10)
        }
    }
    
    private var buttonGroup: some View {
        HStack(spacing: 15) {
            Button("Drop In") {
                // TODO: Implement drop in action
            }
            .buttonStyle(.primary)
            .font(.subheadline)
            
            Button("Not Going") {
                // TODO: Implement not going action
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .controlSize(.large)
        .bold()
    }
}

#Preview {
    EventCard(event: dummyEvent)
}
