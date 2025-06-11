//
//  ProfileEditView.swift
//  dropin
//
//  Created on 28/04/2025.
//


import SwiftUI
import PhotosUI

enum PickerType {
    case avatar, banner
}

/// Displays a view to edit the user profile.
struct ProfileEditView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var activePicker: PickerType?
    @State private var showErrorAlert = false
    
    @State private var bannerImage: BannerImage?
    @State private var avatarImage: AvatarImage?
    
    @State private var bannerImageSelection: PhotosPickerItem?
    @State private var avatarImageSelection: PhotosPickerItem?
    
    @State private var saveTaskStatus: AsyncStatus = .idle

    var body: some View {
        NavigationView {
            Form {
                bannerPickerSection
                avatarPickerSection
            }
            .navigationTitle("Edit Your Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSaveButtonTapped()
                    }
                    .disabled(saveTaskStatus.isRunning)
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("Ok", role: .cancel) {
                    showErrorAlert = false
                }
            } message: {
                Text(saveTaskStatus.error)
            }
        }
    }
    
    private var bannerPickerSection: some View {
        Section(header: Text("Header Banner")) {
            ZStack {
                if let bannerImage {
                    bannerImage.image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 150)
                        .overlay(Text("Tap to select banner"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .onTapGesture { activePicker = .banner }
            .photosPicker(
                isPresented: Binding(get: { activePicker == .banner }, set: { if !$0 { activePicker = nil }}),
                selection: $bannerImageSelection,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: bannerImageSelection) { oldItem, newItem in
                Task {
                    do {
                        if let bannerImageSelection {
                            try await loadBannerImage(selectedBannerItem: bannerImageSelection)
                        }
                    } catch {
                        print("Couldn't load banner image")
                    }
                }
            }
        }
    }
    
    private var avatarPickerSection: some View {
        Section(header: Text("Profile Picture")) {
            HStack {
                Spacer()
                if let avatarImage {
                    avatarImage.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(Text("Tap to select"))
                }
                Spacer()
            }
            .onTapGesture { activePicker = .avatar }
            .photosPicker(
                isPresented: Binding(get: { activePicker == .avatar }, set: { if !$0 { activePicker = nil }}),
                selection: $avatarImageSelection,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: avatarImageSelection) { oldItem, newItem in
                Task {
                    do {
                        if let avatarImageSelection {
                            try await loadAvatarImage(selectedAvatarItem: avatarImageSelection)
                        }
                    } catch {
                        print("Couldn't load avatar image")
                    }
                }
            }
        }
    }
    
    private func onSaveButtonTapped() {
        Task {
            do {
                print("On save button tapped")
                saveTaskStatus = .running
                saveTaskStatus = .success
                if let avatarImage {
                    try await authService.updateAvatar(avatar: avatarImage)
                } else {
                    print("No avatar image to upload")
                }
                if let bannerImage {
                    try await authService.updateBanner(banner: bannerImage)
                    print("No banner image to upload")
                }
                dismiss()
            } catch {
                saveTaskStatus = .failure(error)
                showErrorAlert = true
            }
        }
    }
    
    
    private func loadBannerImage(selectedBannerItem: PhotosPickerItem) async throws {
        bannerImage = try await selectedBannerItem.loadTransferable(type: BannerImage.self)
    }
    
    private func loadAvatarImage(selectedAvatarItem: PhotosPickerItem) async throws {
        avatarImage = try await selectedAvatarItem.loadTransferable(type: AvatarImage.self)
    }
    
}


#Preview {
    ProfileEditView()
        .environment(AuthService())
}
