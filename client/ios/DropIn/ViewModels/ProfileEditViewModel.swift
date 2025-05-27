//
//  ProfileEditViewModel.swift
//  DropIn
//
//  Created by leo on 27.05.2025.
//

import SwiftUI

/// ViewModel to manage profile editing state and actions
@MainActor
@Observable
final class ProfileEditViewModel {
    var name: String = ""
    var username: String = ""
    var isUsernameAvailable: Bool?

    /// Placeholder for async username availability check
    func checkUsernameAvailability() {
        // TODO: Replace with real API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Mock logic: usernames containing "taken" are considered unavailable
            print("Checking availability for username")
        }
    }

    /// Placeholder for save action
    func saveChanges() {
        
    }
    
    
    
}
