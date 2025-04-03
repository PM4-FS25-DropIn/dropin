//
//  EventCategoryTabView.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

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
