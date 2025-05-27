//
//  ProfileEditViewModel.swift
//  DropIn
//
//  Created by leo on 27.05.2025.
//

import SwiftUI
import PhotosUI

/// ViewModel to manage profile editing state and actions
@MainActor
@Observable
final class ProfileEditViewModel {
    var bannerImage: BannerImage?
    var avatarImage: AvatarImage?
    var name: String = ""
    var username: String = ""
    var isUsernameAvailable: Bool?

    /// Placeholder for async username availability check
    func checkUsernameAvailability() {
        
    }
    
    func loadBannerImage(selectedBannerItem: PhotosPickerItem) async throws {
        
        bannerImage = try await selectedBannerItem.loadTransferable(type: BannerImage.self)
    }
    
    func loadAvatarImage(selectedAvatarItem: PhotosPickerItem) async throws {
        
        avatarImage = try await selectedAvatarItem.loadTransferable(type: AvatarImage.self)
    }

    /// Placeholder for save action
    func saveChanges() async throws {
        
    }
    
    
}
