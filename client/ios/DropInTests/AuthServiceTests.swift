//
//  AuthServiceTests.swift
//  DropInTests
//
//  Created by leo on 30.05.2025.
//

import Foundation
import Testing
import Supabase
@testable import DropIn
import UIKit

@MainActor
private let authService = AuthService()

@MainActor
let testUserAuthData = AuthCredentials(username: UUID().uuidString, email: "\(UUID().uuidString.lowercased())@email.com", password: "password")

@MainActor
@Suite(.serialized) struct AuthServiceTests {
    
    @Test("User can sign up")
    func userCanSignUp() async throws {
        try await authService.signUp(authData: testUserAuthData)
        
        try await waitUntil(timeout: 5) {
            authService.isAuthenticated
        }
        
        #expect(authService.isAuthenticated)
    }
    
    @Test("User can sign out")
    func userCanSignOut() async throws {
        try await authService.signOut()
        
        try await waitUntil(timeout: 5) {
            !authService.isAuthenticated
        }
        
        #expect(!authService.isAuthenticated)
    }
    
    @Test("User can sign in")
    func userCanSignIn() async throws {
        try await authService.signIn(authData: testUserAuthData)
        
        try await waitUntil(timeout: 5) {
            authService.isAuthenticated
        }
        
        #expect(authService.isAuthenticated)
    }
    
    @Test("Current User gets current user")
    func currentUserGetsCurrentUser() async throws {
        let currentUser = try await authService.getCurrentUser()
        #expect(currentUser.email == testUserAuthData.email)
    }
    
    @Test("getUsername returns username")
    func getUsernameReturnsUsername() async throws {
        let username = try await authService.getUsername()
        #expect(username == testUserAuthData.username)
    }
    
    @Test("Authservice userid is correct")
    func authserviceUseridIsCorrect() async throws {
        let userId = authService.userId
        #expect(userId != nil)
    }
    
    @Test("getProfile returns correct profile")
    func getProfileReturnsCorrectProfile() async throws {
        let profile = try await authService.getProfile()
        #expect(profile.username == testUserAuthData.username)
    }
    
    @Test("User can update their username")
    func userCanUpdateTheirUsername() async throws {
        let newUsername = UUID().uuidString.lowercased()
        try await authService.updateUsername(newUsername)
        
        let profile: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: authService.userId)
            .single()
            .execute()
            .value
        
        #expect(profile.username == newUsername)
    }
    
    
    @Test("User can upload an avatar")
    func userCanUploadAnAvatar() async throws {
        let avatar = UIImage(systemName: "person.crop.circle.fill")
        
        guard let avatar, let avatarImage = AvatarImage(data: avatar.jpegData(compressionQuality: 0) ?? .empty) else {
            throw AuthServiceError.imageNotFound
        }
        
        try await authService.updateAvatar(avatar: avatarImage)
    }
    
    @Test("User can upload a banner")
    func userCanUploadABanner() async throws {
        let banner = UIImage(systemName: "person.crop.circle.fill")
        
        guard let banner, let bannerImage = BannerImage(data: banner.jpegData(compressionQuality: 0) ?? .empty) else {
            throw AuthServiceError.imageNotFound
        }
        
        try await authService.updateBanner(banner: bannerImage)
    }
    
    @Test("User can update avatar")
    func userCanUpdateAvatar() async throws {
        let avatar = UIImage(systemName: "person.crop.circle")
        
        guard let avatar, let avatarImage = AvatarImage(data: avatar.jpegData(compressionQuality: 0) ?? .empty) else {
            throw AuthServiceError.imageNotFound
        }
        
        try await authService.updateAvatar(avatar: avatarImage)
        
        let userId = try await getUser().id
        
        let files = try await supabase.storage
            .from("avatars")
            .list(
                path: "\(userId)",
                options: SearchOptions(
                    limit: 1,
                    offset: 0
                )
            )
        
        #expect(files.count == 1)
    }
    
    @Test("User can update a banner")
    func userCanUpdateBanner() async throws {
        let banner = UIImage(systemName: "person.crop.circle")
        
        guard let banner, let bannerImage = BannerImage(data: banner.jpegData(compressionQuality: 0) ?? .empty) else {
            throw AuthServiceError.imageNotFound
        }
        
        try await authService.updateBanner(banner: bannerImage)
        
        let userId = try await getUser().id
        
        let files = try await supabase.storage
            .from("banners")
            .list(
                path: "\(userId)",
                options: SearchOptions(
                    limit: 1,
                    offset: 0
                )
            )
        
        #expect(files.count == 1)
    }
    
    
    @Test("Sign in with wrong password fails")
    func signInWithWrongPasswordFails() async throws {
        let wrongAuthData = AuthCredentials(
            username: testUserAuthData.username,
            email: testUserAuthData.email,
            password: "wrongpassword"
        )
        
        await #expect(throws: (any Error).self) {
            try await authService.signIn(authData: wrongAuthData)
        }
    }

    @Test("Get current user throws if not signed in")
    func getCurrentUserThrowsIfNotSignedIn() async throws {
        try await authService.signOut()
        
        await #expect(throws: (any Error).self) {
            try await authService.getCurrentUser()
        }
    }

    @Test("Get username throws if not signed in")
    func getUsernameThrowsIfNotSignedIn() async throws {
        try await authService.signOut()
        
        await #expect(throws: (any Error).self) {
            try await authService.getUsername()
        }
    }

    @Test("Get profile throws if not signed in")
    func getProfileThrowsIfNotSignedIn() async throws {
        try await authService.signOut()
        
        await #expect(throws: (any Error).self) {
            try await authService.getProfile()
        }
    }

    @Test("Update avatar throws with invalid image")
    func updateAvatarThrowsWithInvalidImage() async throws {
        try await authService.signIn(authData: testUserAuthData)
        
        await #expect(throws: (any Error).self) {
            guard let avatarImage = AvatarImage(data: Data()) else {
                throw AuthServiceError.imageNotFound
            }
            try await authService.updateAvatar(avatar: avatarImage)
        }
    }

    @Test("Update banner throws with invalid image")
    func updateBannerThrowsWithInvalidImage() async throws {
        
        await #expect(throws: (any Error).self) {
            guard let bannerImage = BannerImage(data: Data()) else {
                throw AuthServiceError.imageNotFound
            }
            try await authService.updateBanner(banner: bannerImage)
        }
    }
    
    
    private func getUser() async throws -> User {
        return try await supabase.auth.session.user
    }
    
    
    private func waitUntil(timeout: TimeInterval, condition: @escaping () async -> Bool) async throws {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            if await condition() { return }
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        }
        throw AuthServiceError.timeout
    }
    
    private enum AuthServiceError: Error {
        case timeout
        case imageNotFound
    }
}
