//
//  HomeView.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCategory: EventCategory = .forYou
    @State private var events: [DropInEvent] = [dummyEvent]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)
            }
            FriendAvatarCarousel()
            EventCategoryTabView(selectedCategory: $selectedCategory)
                .padding(.horizontal)
                .padding(.vertical, 5)
            
            ScrollView {
                LazyVStack(alignment: .center, spacing: 25) {
                    ForEach(events.indices, id: \.self) { index in
                        EventCard(event: events[index])
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .refreshable {
                // Refresh and fetch new data from db
            }
            .task {
                // Initial fetch from db
            }
        }
    }
}

#Preview {
    HomeView()
}
