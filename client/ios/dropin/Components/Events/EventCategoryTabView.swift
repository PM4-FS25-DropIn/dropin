//
//  EventCategoryTabView.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

enum EventCategory: String, CaseIterable {
    case forYou = "For You"
    case trending = "Trending"
    case nearby = "Nearby"
    case startingSoon = "Starting Soon"
    case ongoing = "Ongoing"
    case sponsored = "Sponsored"
}

struct EventCategoryTabView: View {
    @Binding var selectedCategory: EventCategory
 
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(EventCategory.allCases, id: \.self) { category in
                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundStyle(selectedCategory == category ? .primary : .secondary)
                        .onTapGesture {
                            selectedCategory = category
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    EventCategoryTabView(selectedCategory: .constant(.forYou))
}
