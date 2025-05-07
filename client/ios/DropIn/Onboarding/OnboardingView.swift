//
//  OnboardingView.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPageIndex = 0
    
    var body: some View {
        if currentPageIndex == 0 {
            OnboardingStartView(currentPageIndex: $currentPageIndex)
        } else {
            TabView {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    if index == onboardingPages.count - 1 {
                        VStack {
                            OnboardingPageView(imageName: onboardingPages[index].imageName, title: onboardingPages[index].title, description: onboardingPages[index].description)
                            Button("Sign Up") {
                                showOnboarding.toggle()
                            }
                            .buttonStyle(.primary)
                            .padding()
                        }
                    } else {
                        OnboardingPageView(imageName: onboardingPages[index].imageName, title: onboardingPages[index].title, description: onboardingPages[index].description)
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(false))
}

