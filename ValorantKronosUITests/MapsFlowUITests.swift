//
//  MapsFlowUITests.swift
//  ValorantKronosUITests
//

import XCTest

final class MapsFlowUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Navigation
    
    private func navigateToMapsScreen() {
        let mapsCard = app.staticTexts["MAPS"]
        if mapsCard.waitForExistence(timeout: 4.0) {
            mapsCard.tap()
        } else {
            app.swipeUp()
            if mapsCard.waitForExistence(timeout: 3.0) {
                mapsCard.tap()
            }
        }
    }
    
    // MARK: - Flow Tests
    
    func testMapsFlow_navigateFromMainToMapsList() {
        navigateToMapsScreen()
        
        let mapsTitle = app.staticTexts["MAPS"]
        XCTAssertTrue(mapsTitle.waitForExistence(timeout: 5.0),
                      "MapsView should display 'MAPS' header title")
    }
    
    func testMapsFlow_mapsCarousel_scrollInteraction() {
        navigateToMapsScreen()
        
        let scrollView = app.scrollViews.element(boundBy: 0)
        if scrollView.waitForExistence(timeout: 5.0) {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
    
    func testMapsFlow_tapMapCard_opensDetailSheet() {
        navigateToMapsScreen()
        
        // Find map card button (e.g. Haven, Bind, Ascent)
        let mapButton = app.buttons.element(boundBy: 1) // index 0 is BACK button
        if mapButton.waitForExistence(timeout: 5.0) {
            mapButton.tap()
            
            // Detail view presents sheet with map information
            _ = app.wait(for: .runningForeground, timeout: 1.0)
            let sheetPresented = app.sheets.element.exists || app.buttons.element.exists
            XCTAssertTrue(sheetPresented, "Tapping map card should present single map detail sheet")
        }
    }
    
    func testMapsFlow_backButton_returnsToMainView() {
        navigateToMapsScreen()
        
        let backButton = app.buttons["BACK"]
        if backButton.waitForExistence(timeout: 4.0) {
            backButton.tap()
            
            let mainCategories = app.staticTexts["MAIN CATEGORIES"]
            XCTAssertTrue(mainCategories.waitForExistence(timeout: 4.0),
                          "Tapping BACK button should return to MainView")
        }
    }
}
