//
//  dropinUITests.swift
//  dropinUITests
//
//  Created by leo on 16.03.2025.
//

import XCTest

final class dropinUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        super.setUp()

        // Allow access to Keychain during tests
        let keychainAccessGroup = "YOUR_APP_IDENTIFIER_HERE"  // Replace with your app's identifier
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: kCFBooleanFalse!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecAttrAccessGroup as String: keychainAccessGroup,
            kSecValueData as String: "Test".data(using: .utf8)!,
        ]
        SecItemAdd(attributes as CFDictionary, nil)

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func createAppWithSupabaseEnv() -> XCUIApplication {
        let env = ProcessInfo.processInfo.environment
        let app = XCUIApplication()
        app.launchEnvironment = [
            "SUPABASE_URL": env["SUPABASE_URL"] ?? "",
            "SUPABASE_KEY": env["SUPABASE_KEY"] ?? "",
        ]
        return app
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = createAppWithSupabaseEnv()
        app.launch()

        // Wait for the app to be in a stable state
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    // Fuck this test for now
    /*@MainActor
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = createAppWithSupabaseEnv()
                app.launch()
             }
         }
    }*/
}
