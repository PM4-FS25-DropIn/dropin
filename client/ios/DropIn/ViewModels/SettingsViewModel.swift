//
//  SettingsViewModel.swift
//  dropin
//
//  Created by Moritz Feuchter on 08/05/2025.
//

import Observation  
import SwiftUI

/// View model for handling user settings, including account-related actions
/// like updating email and password.
@Observable
@MainActor
final class SettingsViewModel {
    /// The user's current email address, displayed in the settings screen.
    var email: String = ""

    // MARK: – Account Actions
    /// Simulates updating the user's email address.
    /// Replace with actual backend call in production.
    func updateEmail() async {
        print("Updating email address")
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    /// Attempts to update the user's password with basic validation.
    /// - Parameters:
    ///   - oldPassword: The user's current password.
    ///   - newPassword: The desired new password.
    /// - Throws: An error if input is invalid or policy requirements are not met.
    func updatePassword(oldPassword: String, newPassword: String) async throws {
        guard !oldPassword.isEmpty else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Old password is required"
                ]
            )
        }
        guard newPassword.count >= 8 else {
            throw NSError(
                domain: "Auth",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Password must be at least 8 characters"
                ]
            )
        }
        print("Password updated successfully")
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}
