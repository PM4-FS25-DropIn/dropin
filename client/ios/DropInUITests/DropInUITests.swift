//
//  dropinUITests.swift
//  dropinUITests
//
//  Created by leo on 16.03.2025.
//

import XCTest
import SwiftUI

@MainActor
final class DropInUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws { }
 
    func testCoreViews() throws {
        let app = XCUIApplication()
        app.launch()
        
        testOnboarding(app: app)
        testHomeView(app: app)
        testChatView(app: app)
        testNotificationView(app: app)
        testChatView(app: app)
        testMapView(app: app)
        testDropInsView(app: app)
        testProfileView(app: app)
    }
    
    func testOnboarding(app: XCUIApplication) {
        XCTContext.runActivity(named: "Test onboarding") { activity in
            XCTAssertTrue(app.staticTexts["Welcome to\nDropIn."].waitForExistence(timeout: 1))
            app.buttons["Get Started"].tap()
            
            XCTAssertTrue(app.staticTexts["What is DropIn?"].waitForExistence(timeout: 1))
            app.swipeLeft()
            
            XCTAssertTrue(app.staticTexts["How it Works."].waitForExistence(timeout: 1))
            app.swipeLeft()
            
            XCTAssertTrue(app.staticTexts["Enable Your Location."].waitForExistence(timeout: 1))
            app.swipeLeft()
            
            XCTAssertTrue(app.staticTexts["Stay in the Loop."].waitForExistence(timeout: 1))
            app.swipeLeft()
            
            XCTAssertTrue(app.staticTexts["Time For Adventures!"].waitForExistence(timeout: 1))
            app.buttons["Sign Up"].tap()
        }
    }
    
    func testHomeView(app: XCUIApplication) {
        XCTContext.runActivity(named: "Test home view") { activity in
            XCTAssertTrue(app.staticTexts["Join nearby events"].exists)
            
            // Category Switcher
            XCTAssertTrue(app.staticTexts["For You"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.staticTexts["Ongoing"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.staticTexts["Starting Soon"].waitForExistence(timeout: 1))
        }
    }
    
    func testNotificationView(app: XCUIApplication) {
        XCTContext.runActivity(named: "Test notification view") { activity in
            app.buttons["bell.fill"].tap()
            app.buttons["Back"].tap()
        }
    }
    
    func testChatView(app: XCUIApplication) {
        XCTContext.runActivity(named: "Test chat view") { activity in
            app/*@START_MENU_TOKEN@*/.buttons["paperplane.fill"]/*[[".otherElements",".buttons[\"Send\"]",".buttons[\"paperplane.fill\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.buttons["Back"].tap()
        }
    }
    
    func testMapView(app: XCUIApplication) {
        XCTContext.runActivity(named: "Test map view") { activity in
            app/*@START_MENU_TOKEN@*/.tabBars.buttons["Map"]/*[[".tabBars.buttons[\"Map\"]",".buttons[\"Map\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
            
            XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 1))
        }
    }
    
    func testDropInsView(app: XCUIApplication) {
        XCTContext.runActivity(named: "Test DropIns view") { activity in
            app.tabBars.buttons["DropIns"].tap()
            
            XCTAssertTrue(app.staticTexts["Up Next"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.buttons["All DropIns"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.buttons["My DropIns"].waitForExistence(timeout: 1))
        }
    }
    
    func testProfileView(app: XCUIApplication) {
        XCTContext.runActivity(named: "Test Profile view") { activity in
            app.tabBars.buttons["Profile"].tap()
            
            XCTAssertTrue(app.staticTexts["DropIns created"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.staticTexts["DropIns attended"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.staticTexts["My DropIns"].waitForExistence(timeout: 1))
            
            app.buttons["info.circle.fill"].tap()
            
            XCTAssertTrue(app.staticTexts["ACCOUNT"].waitForExistence(timeout: 1))
            XCTAssertTrue(app.staticTexts["SUPPORT & ABOUT"].waitForExistence(timeout: 1))
            app.buttons["Back"].tap()
        }
    }
    
    
    func testCreateEvent() throws {
        let app = XCUIApplication()
        app.launch()
        
        app/*@START_MENU_TOKEN@*/.buttons["plus"]/*[[".otherElements",".buttons[\"Add\"]",".buttons[\"plus\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.textFields["Title"]/*[[".otherElements.textFields[\"Title\"]",".textFields.firstMatch",".textFields[\"Title\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssertTrue(app.staticTexts["What's going on?"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.textFields["Title"].waitForExistence(timeout: 1))
        
        app.otherElements.firstMatch.swipeLeft()
        XCTAssertTrue(app.staticTexts["Where's the DropIn?"].waitForExistence(timeout: 1))
        
        app.staticTexts["Where's the DropIn?"].swipeLeft()
        XCTAssertTrue(app.staticTexts["When is it happening?"].waitForExistence(timeout: 1))
        
        app.otherElements.firstMatch.swipeLeft()
        XCTAssertTrue(app.staticTexts["Who can join?"].waitForExistence(timeout: 1))
        
        app.otherElements.firstMatch.swipeLeft()
        XCTAssertTrue(app.staticTexts["Show it off!"].waitForExistence(timeout: 1))
        
        app.otherElements.firstMatch.swipeLeft()
        XCTAssertTrue(app.staticTexts["Ready to Launch?"].waitForExistence(timeout: 1))
    }
    
    
    
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
         }
    }
}
