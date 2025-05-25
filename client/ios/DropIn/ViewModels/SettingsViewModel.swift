//
//  SettingsViewModel.swift
//  dropin
//
//  Created by Moritz Feuchter on 08/05/2025.
//

import Observation  // new Observation framework
import SwiftUI

@Observable
@MainActor
final class SettingsViewModel {
    // Account
    var email: String = ""

    // Notifications
    var eventNotificationsEnabled: Bool = true
    var chatNotificationsEnabled: Bool = true

    // Appearance
    enum AppTheme: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: Self { self }
    }
    var selectedTheme: AppTheme = .system

    // MARK: – Account Actions
    func updateEmail() async {
        print("Updating email address")
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

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
