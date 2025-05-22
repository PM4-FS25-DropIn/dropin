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
        HStack {
            ForEach(EventCategory.allCases.indices, id: \.self) { index in
                let category = EventCategory.allCases[index]

                if index != 0 {
                    Spacer()
                }

                Text(category.rawValue)
                    .font(.headline)
                    .foregroundStyle(selectedCategory == category ? .primary : .secondary)
                    .onTapGesture {
                        selectedCategory = category
                    }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EventCategoryTabView(selectedCategory: .constant(.forYou))
}
