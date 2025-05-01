//
//  LocationPermissionError.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI
import MapKit

enum LocationPermissionError: Error {
    case globalAuthDeniedError(String)
    case authDeniedError(String)
    case authRestrictedError(String)
    case accuracyLimitedError(String)
    case alwaysAuthDeniedError(String)
}

// TODO: Make this an environment
@MainActor
@Observable
final class LocationService {
    
    @ObservationIgnored static let shared = LocationService()
    
    var lastUpdate: CLLocationUpdate?
    var lastLocation = CLLocation()
    var isStationary = false
    var lastDiagnosticUpdate: CLServiceSession.Diagnostic?
    
    var hasPermission: Bool = false
    
    private var serviceSession: CLServiceSession?
    
    private(set) var isEnabled: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "liveUpdatesStarted")
        }
    }
    
    private init() { }
    
    func enable() {
        isEnabled = true
        serviceSession = CLServiceSession(authorization: .whenInUse)
        runDiagnostics()
        startLocationUpdates()
    }
    
    func disable() {
        isEnabled = false
        serviceSession?.invalidate()
        stopLocationUpdates()
    }
    
    func runDiagnostics() {
        Task {
            guard let serviceSession else { return }
            for try await diagnostic in serviceSession.diagnostics {
                lastDiagnosticUpdate = diagnostic
                if (diagnostic.alwaysAuthorizationDenied) {
                    print("Always authorization denied")
                    hasPermission = false
                } else if (diagnostic.authorizationDenied) {
                    print("Authorization denied")
                    hasPermission = false
                } else if (diagnostic.authorizationDeniedGlobally) {
                    print("Authorization denied globally")
                    hasPermission = false
                } else if (diagnostic.authorizationRequestInProgress) {
                    print("Requesting Authorization")
                    hasPermission = false
                } else if (diagnostic.fullAccuracyDenied) {
                    print("Full accurracy denied")
                    hasPermission = false
                } else if (diagnostic.insufficientlyInUse) {
                    print("Insufficiently in use")
                    hasPermission = false
                } else {
                    hasPermission = true
                }
            }
        }
    }
    
    private func startLocationUpdates() {
        let sessionID = UUID().uuidString
        print("Starting location updates - session \(sessionID)")
        Task {
            do {
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    print("Session \(sessionID): New location update.")
                    if !self.isEnabled { break }
                    self.lastUpdate = update
                    if let loc = update.location {
                        self.lastLocation = loc
                        self.isStationary = update.stationary
                    }
                }
            } catch {
                print("Couldn't start location updates")
            }
        }
    }
    
    private func stopLocationUpdates() {
        print("Stopping location updates")
    }
    
}