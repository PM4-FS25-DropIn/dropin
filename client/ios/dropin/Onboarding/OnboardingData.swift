//
//  OnboardingData.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import Foundation

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

let onboardingPages = [
    OnboardingPage(
        title: "What is DropIn?",
        description:
            """
            Find and join spontaneous events near you. 
            No planning, just drop in!
            """,
        imageName: "Onboarding/hangout"),
    OnboardingPage(
        title: "How it Works.",
        description:
            """
            Browse real-time events on a map. 
            Tap to join instantly or host your own!
            """,
        imageName: "Onboarding/location"),
    OnboardingPage(
        title: "Stay in the Loop.",
        description:
            """
            Get notified when cool events pop up near you.
            """,
        imageName: "Onboarding/notification"),
    OnboardingPage(
        title: "Time For Adventures!",
        description:
            """
            Start discovering events around you and have fun.
            """,
        imageName: "Onboarding/explore"),
]
