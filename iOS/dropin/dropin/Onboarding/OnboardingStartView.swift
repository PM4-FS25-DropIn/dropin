//
//  OnboardingStartView.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

struct OnboardingStartView: View {
    @Binding var currentPageIndex: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("Onboarding/welcome")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding()
            Text("Welcome to\nDropIn.")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Spontaneous meetups,\nno planning needed.")
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Button("Get Started") {
                currentPageIndex += 1
            }
            .buttonStyle(.primary)
            .padding()
        }
        .multilineTextAlignment(.center)
        
    }
}

#Preview {
    OnboardingStartView(currentPageIndex: .constant(0))
}
