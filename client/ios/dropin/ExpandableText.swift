import SwiftUI


private struct FullHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct LimitedHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ExpandableText: View {
    let text: String
    let lineLimit: Int

    @State private var isExpanded: Bool = false
    @State private var fullHeight: CGFloat = 0
    @State private var limitedHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            // Hidden measurements
            ZStack {
                // 1) full height
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: FullHeightKey.self,
                                value: geo.size.height
                            )
                        }
                    )
                    .hidden()

                // 2) limited height
                Text(text)
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: LimitedHeightKey.self,
                                value: geo.size.height
                            )
                        }
                    )
                    .hidden()
            }
            .frame(height: 0) // Hide the ZStack

            Text(text)
                .lineLimit(isExpanded ? nil : lineLimit)
                .animation(.easeInOut, value: isExpanded)

            // Only show the "Read More" button when collapsed.
            if !isExpanded && fullHeight > limitedHeight {
                Button("Read More") {
                    withAnimation {
                        isExpanded = true
                    }
                }
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }
        }

        .onPreferenceChange(FullHeightKey.self) { fullHeight = $0 }
        .onPreferenceChange(LimitedHeightKey.self) { limitedHeight = $0 }
    }
}
