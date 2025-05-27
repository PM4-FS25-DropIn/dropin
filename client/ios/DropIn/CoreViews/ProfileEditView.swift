//
//  ProfileEditView.swift
//  dropin
//
//  Created on 28/04/2025.
//


import SwiftUI
import PhotosUI

/// Root view for editing a user profile
struct ProfileEditView: View {
    @State private var viewModel = ProfileEditViewModel()
    @State private var isPickerPresented = false
    @State private var selectedBannerImage: PhotosPickerItem?
    @State private var selectedProfileImage: PhotosPickerItem?

    var body: some View {
        NavigationView {
            Form {
                bannerPickerSection
                avatarPickerSetion
                basicInfoSection
            }
            .navigationTitle("Edit Your Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // viewModel.saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var bannerPickerSection: some View {
        Section(header: Text("Header Banner")) {
            ZStack {
                if let uiImage = viewModel.bannerImage {
                    Image(uiImage: uiImage)
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
            .onTapGesture { isPickerPresented = true }
            .photosPicker(
                isPresented: $isPickerPresented,
                selection: $selectedBannerImage,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedBannerImage) { oldItem, newItem in
                loadImage(from: newItem) { image in
                    viewModel.bannerImage = image
                }
            }
        }
    }
    
    private var avatarPickerSetion: some View {
        Section(header: Text("Profile Picture")) {
            HStack {
                Spacer()
                if let uiImage = viewModel.avatarImage {
                    Image(uiImage: uiImage)
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
            .onTapGesture { isPickerPresented = true }
            .photosPicker(
                isPresented: $isPickerPresented,
                selection: $selectedProfileImage,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedProfileImage) { oldItem, newItem in
                loadImage(from: newItem) { image in
                    viewModel.avatarImage = image
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section(header: Text("Basic Info")) {
            TextField("Name", text: $viewModel.name)
                .autocapitalization(.words)
            VStack(alignment: .leading, spacing: 4) {
                TextField("Username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.username) { oldItem, _ in
                        viewModel.checkUsernameAvailability()
                    }
                if let available = viewModel.isUsernameAvailable {
                    Text(available ? "Username is available" : "Username is taken")
                        .font(.caption)
                        .foregroundColor(available ? .green : .red)
                }
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?, completion: @escaping (UIImage?) -> Void) {
        guard let item = item else { return completion(nil) }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }

    /// Determines if "Save" should be enabled
    private var canSave: Bool {
        !viewModel.name.isEmpty && viewModel.isUsernameAvailable == true
        
    }
}


#Preview {
    ProfileEditView()
        .environment(AuthService())
}
