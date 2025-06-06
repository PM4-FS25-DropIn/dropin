import SwiftUI
import MapKit

enum LocationPermissionError: Error {
    case globalAuthDeniedError(String)
    case authDeniedError(String)
    case authRestrictedError(String)
    case accuracyLimitedError(String)
    case alwaysAuthDeniedError(String)
}

/// A singleton service that manages live location updates and diagnostics.
/// Handles permission checks and update control for DropIn's location features.
@MainActor
@Observable
final class LocationService {
    
    /// Shared singleton instance of LocationService.
    @ObservationIgnored static let shared = LocationService()
    
    /// The most recent location update received.
    var lastUpdate: CLLocationUpdate?
    /// The most recent CLLocation object received.
    var lastLocation = CLLocation()
    /// Indicates whether the user is currently stationary.
    var isStationary = false
    /// The last diagnostic update from Core Location services.
    var lastDiagnosticUpdate: CLServiceSession.Diagnostic?
    
    /// Indicates whether location permission has been granted.
    var hasPermission: Bool = false
    
    private var serviceSession: CLServiceSession?
    
    /// Controls whether location updates are enabled.
    /// Persists across launches using UserDefaults.
    private(set) var isEnabled: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "liveUpdatesStarted")
        }
    }
    
    private init() { }
    
    /// Enables location tracking and starts collecting updates.
    func enable() {
        print("Enabling location service...")
        isEnabled = true
        serviceSession = CLServiceSession(authorization: .whenInUse)
        runDiagnostics()
        startLocationUpdates()
    }
    
    /// Disables location tracking and stops update collection.
    func disable() {
        isEnabled = false
        serviceSession?.invalidate()
        stopLocationUpdates()
    }
    
    /// Performs diagnostic checks on location permissions and service state.
    /// Updates `hasPermission` based on the diagnostic results.
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
    
    /// Starts listening for live location updates in a background task.
    /// Updates internal state with new location data.
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
    
    /// Placeholder to stop location updates. Can be expanded for cleanup logic.
    private func stopLocationUpdates() {
        print("Stopping location updates")
    }
}
