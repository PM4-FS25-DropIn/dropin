import SwiftUI

struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .lineLimit(isExpanded ? nil : lineLimit)
                .animation(.easeInOut, value: isExpanded)
            
            // Only show the "Read More" button when collapsed.
            if !isExpanded {
                Button("Read More") {
                    withAnimation {
                        isExpanded = true
                    }
                }
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
