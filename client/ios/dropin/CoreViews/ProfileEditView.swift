//
//  ProfileEditViewModel.swift
//  dropin
//
//  Created on 28/04/2025.
//


import SwiftUI
import PhotosUI

/// ViewModel to manage profile editing state and actions
final class ProfileEditViewModel: ObservableObject {
    @Published var bannerImage: UIImage?
    @Published var avatarImage: UIImage?
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var isUsernameAvailable: Bool?

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
        // TODO: Implement save logic (API call, persistence, etc.)
        print("Saving profile: name=\(name), username=\(username)")
    }
}

/// Root view for editing a user profile
struct ProfileEditView: View {
    @StateObject private var viewModel = ProfileEditViewModel()

    var body: some View {
        NavigationView {
            Form {
                BannerPickerSection(viewModel: viewModel)
                AvatarPickerSection(viewModel: viewModel)
                BasicInfoSection(viewModel: viewModel)
            }
            .navigationTitle("Edit Your Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
