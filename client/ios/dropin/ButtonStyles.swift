//
//  ButtonStyles.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .bold()
            .foregroundStyle(.white)
            .background(.pacificCyan)
            .clipShape(Capsule(style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}
