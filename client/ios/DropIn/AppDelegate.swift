import SwiftUI
import UIKit

@Observable
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let locationService = LocationService.shared
        
        // If location updates were previously active, restart them after the background launch.
        if locationService.isEnabled {
            print("Running app delegate enable")
            locationService.enable()
        }
        // If a background activity session was previously active, reinstantiate it after the background launch.
        /*if locationService.backgroundActivity {
            locationService.backgroundActivity = true
        }*/
        return true
    }
}

