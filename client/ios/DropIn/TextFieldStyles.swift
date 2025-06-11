import SwiftUI

struct RoundedTextFieldStyle: ViewModifier {
    var strokeColor: Color = .primary
    var cornerRadius: CGFloat = 30

    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor)
            )
    }
}

extension View {
    func roundedTextFieldStyle(
        strokeColor: Color = .primary,
        cornerRadius: CGFloat = 30
    ) -> some View {
        self.modifier(RoundedTextFieldStyle(strokeColor: strokeColor, cornerRadius: cornerRadius))
    }
}
