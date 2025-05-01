//
//  ProfileEditView.swift
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

    /// Determines if "Save" should be enabled
    private var canSave: Bool {
        !viewModel.name.isEmpty && viewModel.isUsernameAvailable == true
    }
}

// MARK: - Modular Sections

/// Section for picking a header/banner image
struct BannerPickerSection: View {
    @ObservedObject var viewModel: ProfileEditViewModel
    @State private var pickerItem: PhotosPickerItem?
    @State private var isPickerPresented = false

    var body: some View {
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
                }
            }
            .cornerRadius(8)
            .onTapGesture { isPickerPresented = true }
            .photosPicker(
                isPresented: $isPickerPresented,
                selection: $pickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: pickerItem) { oldItem, newItem in
                loadImage(from: newItem) { image in
                    viewModel.bannerImage = image
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
}

/// Section for picking a profile/avatar image
struct AvatarPickerSection: View {
    @ObservedObject var viewModel: ProfileEditViewModel
    @State private var pickerItem: PhotosPickerItem?
    @State private var isPickerPresented = false

    var body: some View {
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
                selection: $pickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: pickerItem) { oldItem, newItem in
                loadImage(from: newItem) { image in
                    viewModel.avatarImage = image
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
}

/// Section for editing basic textual profile info
struct BasicInfoSection: View {
    @ObservedObject var viewModel: ProfileEditViewModel

    var body: some View {
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
}

#Preview {
    ProfileEditView()
        .environment(AuthService())
}
