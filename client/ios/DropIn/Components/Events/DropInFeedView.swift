//
//  DropInFeedView.swift
//  DropIn
//
//  Created by leo on 26.05.2025.
//

import SwiftUI
import Kingfisher

/// Displays the joined events of a user in the ProfileView.
struct DropInFeedView: View {
    @Environment(AuthService.self) private var authService
    @Environment(EventStore.self) private var eventStore
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            Text("My DropIns")
                .font(.headline)
            
            if eventStore.joinedEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No DropIns yet...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(eventStore.joinedEvents.filter { $0.userId == authService.userId }) { event in
                    rowItem(event: event)
                }
            }
        }
    }
    
    
    private func rowItem(event: DropInEvent) -> some View {
        HStack {
            rowImage(event: event)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.caption)
                    .bold()
                Text(event.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(4)
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    
    private func rowImage(event: DropInEvent) -> some View {
        Group {
            if let eventImagePath = event.imagePaths?.first {
                KFImage(URL(string: eventImagePath))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            } else {
                Image("default.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
        }
    }
    
}
