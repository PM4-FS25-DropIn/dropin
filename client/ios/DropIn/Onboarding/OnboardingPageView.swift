//
//  OnboardingPageView.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
       
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 200)
            Text(title)
                .font(.title2)
                .bold()
            Text(description)
                .font(.caption)
                .bold()
                .foregroundStyle(.gray)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .frame(width: 350, height: 450)
    }
}

#Preview {
    OnboardingPageView(imageName: "Onboarding/welcome", title: "Title", description: "Description")
}
