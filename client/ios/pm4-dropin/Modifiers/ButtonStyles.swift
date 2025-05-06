import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.controlSize) var controlSize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(padding(for: controlSize))
            .foregroundStyle(.white)
            .background(.pacificCyan)
            .clipShape(Capsule())
    }
    
    private func padding(for size: ControlSize) -> EdgeInsets {
           switch size {
           case .mini: EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
           case .small: EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
           case .regular: EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
           case .large: EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
           case .extraLarge: EdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
           @unknown default: EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
           }
       }
    
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}
