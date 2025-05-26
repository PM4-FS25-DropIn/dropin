import Foundation
import Auth

@MainActor
@Observable
final class AuthService {
    private(set) var isAuthenticated = false
    
    var userId: UUID?
    
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
    
}

enum AuthServiceError: Error {
    case profileNotFound
}
