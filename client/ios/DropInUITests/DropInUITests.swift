//
//  dropinUITests.swift
//  dropinUITests
//
//  Created by leo on 16.03.2025.
//

import XCTest

final class DropInUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = createAppWithSupabaseEnv()
        app.launch()

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
    
    func testEventCategoryTab() throws {
        let app = XCUIApplication()
        app.launch()

        let labels = ["For You", "Trending", "Nearby", "Starting Soon", "Ongoing", "Sponsored"]

        measure {
            for label in labels {
                let element = app.staticTexts[label]
                XCTAssertTrue(element.waitForExistence(timeout: 5), "\(label) should exist")
                element.tap()
            }

            // Swipe interaction
            let ongoing = app.scrollViews.staticTexts["Ongoing"]
            XCTAssertTrue(ongoing.exists, "Ongoing label should exist in scroll view")
            ongoing.swipeLeft()
        }
    }
    func testHomeView() throws {
        let app = XCUIApplication()
        app.launch()
        measure {
            app/*@START_MENU_TOKEN@*/.buttons["paperplane.fill"]/*[[".otherElements",".buttons[\"Send\"]",".buttons[\"paperplane.fill\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            let backButton = app/*@START_MENU_TOKEN@*/.buttons["Back"]/*[[".navigationBars",".buttons.firstMatch",".buttons[\"Back\"]"],[[[-1,2],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
            backButton.tap()
            app/*@START_MENU_TOKEN@*/.buttons["bell.fill"]/*[[".otherElements",".buttons[\"Notifications\"]",".buttons[\"bell.fill\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            backButton.tap()
        }
    }
}
