//
//  dropinUITestsLaunchTests.swift
//  dropinUITests
//
//  Created by leo on 16.03.2025.
//

import XCTest

final class DropInUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor func createAppWithSupabaseEnv() -> XCUIApplication {
        let env = ProcessInfo.processInfo.environment
        let app = XCUIApplication()
        app.launchEnvironment = [
            "SUPABASE_URL": env["SUPABASE_URL"] ?? "",
            "SUPABASE_KEY": env["SUPABASE_KEY"] ?? ""
        ]
        return app
    }

    @MainActor
    func testLaunch() throws {
        let app = createAppWithSupabaseEnv()

        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
