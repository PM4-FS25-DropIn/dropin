import Foundation
import Auth

@MainActor
@Observable
final class AuthService {
    
    enum AuthServiceError: Error {
        case profileNotFound
    }
    
    private(set) var isAuthenticated = false
    
    init() {
        Task {
            await setupAuthListeners()
        }
    }
    
    func setupAuthListeners() async {
        for await state in supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                isAuthenticated = state.session != nil
            //    print("Authentication status is: \(isAuthenticated)")
            }
        }
    }
    
    func signIn(authData: AuthCredentials) async throws {
        try await supabase.auth.signIn(email: authData.email, password: authData.password)
    }
    
    func signUp(authData: AuthCredentials) async throws {
        try await supabase.auth.signUp(email: authData.email, password: authData.password,data: ["username": .string(authData.username)])
    }
    
    func signUpOTP(authData: AuthCredentials, code: String) async throws {
        try await supabase.auth.verifyOTP(email: authData.email, token: code, type: .signup)
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    func getCurrentUser() async throws -> User {
        return try await supabase.auth.session.user
    }
    
    
    func getUser() async throws -> Profile {
        let user = try await getCurrentUser()

        let profiles: [Profile] = try await supabase
            .from("profiles")
            .select("id, username, avatar_url")
            .eq("id", value: user.id)
            .limit(1)
            .execute()
            .value

        guard let profile = profiles.first else {
            throw AuthServiceError.profileNotFound
        }

        return profile
    }
    
    
}
