import Foundation
import Storage
import Auth

/// A service responsible for managing user authentication, session handling,
/// and profile updates using Supabase.
@MainActor
@Observable
final class AuthService {
    /// Indicates whether a user is currently authenticated.
    private(set) var isAuthenticated = false
    
    /// The unique identifier of the currently signed-in user.
    var userId: UUID?
    /// The current authenticated user session.
    var user: User?
    
    /// Initializes the AuthService and sets up auth state listeners.
    init() {
        Task {
            await setupAuthListeners()
        }
    }
    
    /// Observes authentication state changes and updates the user session accordingly.
    func setupAuthListeners() async {
        for await state in supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                isAuthenticated = state.session != nil
                if isAuthenticated {
                    userId = state.session?.user.id
                    user = state.session?.user
                }
            }
        }
    }
    
    /// Signs in a user using email and password credentials.
    func signIn(authData: AuthCredentials) async throws {
        try await supabase.auth.signIn(email: authData.email, password: authData.password)
    }
    
    /// Signs up a user with email, password, and username metadata.
    func signUp(authData: AuthCredentials) async throws {
        print("Signing up here...")
        try await supabase.auth.signUp(email: authData.email, password: authData.password, data: ["username": .string(authData.username)])
    }
    /// Checks if a given username is available in the database.
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let result = try await supabase
            .from("profiles")
            .select("id", head: true, count: .exact)
            .eq("username", value: username)
            .execute()
        
        return (result.count ?? 0) == 0
    }
    
    /// Signs the current user out of their session.
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    /// Returns the currently signed-in user.
    func getCurrentUser() async throws -> User {
        return try await supabase.auth.session.user
    }
    
    /// Retrieves the username of the current user from the profile.
    func getUsername() async throws -> String {
        let profile: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value

        print("Profile found and it's: \(profile.username)")
        return profile.username
    }
    
    /// Verifies a one-time password (OTP) for email signup.
    func signUpOTP(authData: AuthCredentials, code: String) async throws {
        try await supabase.auth.verifyOTP(email: authData.email, token: code, type: .signup)
    }
    
    /// Retrieves the full profile of the current user.
    func getProfile() async throws -> Profile {
        let profile: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        return profile
    }
    
    /// Updates the username of the current user.
    func updateUsername(_ username: String) async throws {
        try await supabase
            .from("profiles")
            .update(["username": username])
            .eq("id", value: userId)
            .execute()
    }
    
    /// Updates the avatar image for the current user.
    func updateAvatar(avatar: AvatarImage) async throws {
        guard let filePath = try await uploadAvatarImage(avatar.data) else { return }
        
        if let userId {
            let publicFileUrl = try supabase.storage
                .from("avatars")
                .getPublicURL(path: filePath)
            
            try await supabase
                .from("profiles")
                .update(["avatar_url": publicFileUrl])
                .eq("id", value: userId)
                .execute()
            print("Updated avatar")
        }
        print("Done avatar.")
    }
    
    /// Uploads or replaces the avatar image in Supabase Storage.
    private func uploadAvatarImage(_ imageData: Data) async throws -> String? {
        guard let userId else { return nil }
        let filePath = "\(userId.uuidString.lowercased())/\(UUID().uuidString)"
        
        let filesInFolder = try await getFilesInFolder(bucket: "avatars", folder: userId.uuidString.lowercased())
        
        if filesInFolder.isEmpty {
            try await supabase.storage
                .from("avatars")
                .upload(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        cacheControl: "3600",
                        contentType: "image/jpeg",
                        upsert: false
                    )
                )
        } else {
            print("Folder not empty. Updating avatar...")
            try await supabase.storage
                .from("avatars")
                .remove(paths: ["\(userId.uuidString.lowercased())/\(filesInFolder[0].name)"])
            
            try await supabase.storage
                .from("avatars")
                .update(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        cacheControl: "3600",
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )
        }
        
        return filePath
    }
    
    /// Updates the banner image for the current user.
    func updateBanner(banner: BannerImage) async throws {
        guard let filePath = try await uploadBannerImage(banner.data) else { return }
        
        if let userId {
            let publicFileUrl = try supabase.storage
                .from("banners")
                .getPublicURL(path: filePath)
            
            try await supabase
                .from("profiles")
                .update(["banner_url": publicFileUrl])
                .eq("id", value: userId)
                .execute()
        }
    }
    
    /// Lists files in a specific storage bucket folder.
    private func getFilesInFolder(bucket: String, folder: String) async throws -> [FileObject] {
        let files = try await supabase.storage
            .from(bucket)
            .list(
                path: folder,
                options: SearchOptions(
                    limit: 1,
                    offset: 0
                    )
            )
        print("Files returned \(files.count)")
        return files
    }
    
    /// Uploads or replaces the banner image in Supabase Storage.
    private func uploadBannerImage(_ imageData: Data) async throws -> String? {
        guard let userId else { return nil }
        let filePath = "\(userId.uuidString.lowercased())/\(UUID().uuidString)"
        
        let filesInFolder = try await getFilesInFolder(bucket: "banners", folder: userId.uuidString.lowercased())
        
        if filesInFolder.isEmpty {
            try await supabase.storage
                .from("banners")
                .upload(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        cacheControl: "3600",
                        contentType: "image/jpeg",
                        upsert: false
                    )
                )
        } else {
            print("Files in folder name \(filesInFolder[0].name)")
            try await supabase.storage
                .from("banners")
                .remove(paths: ["\(userId.uuidString.lowercased())/\(filesInFolder[0].name)"])
            
            try await supabase.storage
                .from("banners")
                .update(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        cacheControl: "3600",
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )
        }
        return filePath
    }
    
}

enum AuthServiceError: Error {
    case profileNotFound
}
