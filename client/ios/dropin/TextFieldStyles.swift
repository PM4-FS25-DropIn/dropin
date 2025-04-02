import SwiftUI

struct RoundedTextFieldStyle: ViewModifier {
    var strokeColor: Color = Color(red: 227/255, green: 227/255, blue: 227/255)
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
        strokeColor: Color = Color(red: 227/255, green: 227/255, blue: 227/255),
        cornerRadius: CGFloat = 30
    ) -> some View {
        self.modifier(RoundedTextFieldStyle(strokeColor: strokeColor, cornerRadius: cornerRadius))
    }
}
