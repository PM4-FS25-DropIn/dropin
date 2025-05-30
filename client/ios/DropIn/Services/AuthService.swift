import Foundation
import Storage
import Auth

@MainActor
@Observable
final class AuthService {
    private(set) var isAuthenticated = false
    
    var userId: UUID?
    var user: User?
    
    init() {
        Task {
            await setupAuthListeners()
        }
    }
    
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
    
    func signIn(authData: AuthCredentials) async throws {
        try await supabase.auth.signIn(email: authData.email, password: authData.password)
    }
    
    func signUp(authData: AuthCredentials) async throws {
        print("Signing up here...")
        try await supabase.auth.signUp(email: authData.email, password: authData.password, data: ["username": .string(authData.username)])
    }
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let result = try await supabase
            .from("profiles")
            .select("id", head: true, count: .exact)
            .eq("username", value: username)
            .execute()
        
        return (result.count ?? 0) == 0
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    func getCurrentUser() async throws -> User {
        return try await supabase.auth.session.user
    }
    
    
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
    
    func signUpOTP(authData: AuthCredentials, code: String) async throws {
        try await supabase.auth.verifyOTP(email: authData.email, token: code, type: .signup)
    }
    
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
    
    func updateUsername(_ username: String) async throws {
        try await supabase
            .from("profiles")
            .update(["username": username])
            .eq("id", value: userId)
            .execute()
    }
    
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
    
    private func uploadAvatarImage(_ imageData: Data) async throws -> String? {
        guard let userId else { return nil }
        let filePath = "\(userId.uuidString.lowercased())/\(UUID().uuidString)"
        
        if try await isFolderEmpty(bucket: "avatars", folder: userId.uuidString) {
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
    
    private func isFolderEmpty(bucket: String, folder: String) async throws -> Bool {
        let files = try await supabase.storage
            .from(bucket)
            .list(
                path: folder,
                options: SearchOptions(
                    limit: 1,
                    offset: 0,
                    )
            )
        print("Files returned \(files.count)")
        return files.isEmpty
    }
    
    private func uploadBannerImage(_ imageData: Data) async throws -> String? {
        guard let userId else { return nil }
        let filePath = "\(userId.uuidString.lowercased())/\(UUID().uuidString)"
        
        
        if try await isFolderEmpty(bucket: "banners", folder: userId.uuidString) {
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
