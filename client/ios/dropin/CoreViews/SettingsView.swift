//
//  SettingsView.swift
//  dropin
//
//  Created on 08/05/2025.
//

import SwiftUI
import Observation

struct SettingsView: View {
    @State private var vm = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                AccountSection(vm: vm)
                NotificationsSection(vm: vm)
                AppearanceSection(vm: vm)
                SupportSection()
                DangerZoneSection(vm: vm)
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(5)
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Change Password View

struct ChangePasswordView: View {
    let vm: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        Form {
            Section {
                SecureField("Current Password", text: $oldPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
            }

            Section {
                Button("Change Password") {
                    guard validatePasswords() else { return }
                    Task {
                        do {
                            try await vm.updatePassword(
                                oldPassword: oldPassword,
                                newPassword: newPassword
                            )
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .alert("Password Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func validatePasswords() -> Bool {
        guard !oldPassword.isEmpty else {
            errorMessage = "Please enter your current password"
            showError = true
            return false
        }
        guard !newPassword.isEmpty else {
            errorMessage = "Please enter a new password"
            showError = true
            return false
        }

        let trimmedNew = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedNew == trimmedConfirm else {
            errorMessage = "New passwords don't match"
            showError = true
            return false
        }

        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        guard predicate.evaluate(with: newPassword) else {
            errorMessage =
                "Password must contain:\n• 8+ characters\n• A number\n• A special character (@$!%*#?&)"
            showError = true
            return false
        }

        return true
    }
}
