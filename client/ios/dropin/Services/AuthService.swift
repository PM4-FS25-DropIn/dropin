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
            userId = try await getCurrentUser().id
        }
    }
    
    func setupAuthListeners() async {
        for await state in supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                isAuthenticated = state.session != nil
            }
        }
    }
    
    func signIn(authData: AuthCredentials) async throws {
        try await supabase.auth.signIn(email: authData.email, password: authData.password)
    }
    
    func signUp(authData: AuthCredentials) async throws {
        try await supabase.auth.signUp(email: authData.email, password: authData.password, data: ["username": .string(authData.username)])
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    func getCurrentUser() async throws -> User {
        return try await supabase.auth.session.user
    }
    
    func getUsername() async throws -> String {
        let user = try await getCurrentUser()

        let profiles: [Profile] = try await supabase
            .from("profiles")
            .select("username")
            .eq("id", value: user.id)
            .limit(1)
            .execute()
            .value

        guard let profile = profiles.first else {
            throw AuthServiceError.profileNotFound
        }

        return profile.username ?? "unknown"
    }
    
}

enum AuthServiceError: Error {
    case profileNotFound
}
