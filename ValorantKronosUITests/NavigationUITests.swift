//
//  NavigationUITests.swift
//  ValorantKronosUITests
//

import XCTest

final class NavigationUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - TabBar Navigation Tests
    
    func testNavigation_initialLaunch_defaultsToMainTab() {
        // Main view should display the hero typography and main categories section
        let weAreText = app.staticTexts["WE ARE"]
        let mainCategoriesText = app.staticTexts["MAIN CATEGORIES"]
        
        XCTAssertTrue(weAreText.waitForExistence(timeout: 5.0) || mainCategoriesText.waitForExistence(timeout: 5.0),
                      "Main view hero content should be visible on initial launch")
    }
    
    func testNavigation_switchToCategoriesTab() {
        let tabBars = app.tabBars
        let categoriesTab = tabBars.buttons.element(boundBy: 0)
        
        if categoriesTab.waitForExistence(timeout: 3.0) {
            categoriesTab.tap()
            
            // Categories view contains "Category" placeholder or category content
            let categoryText = app.staticTexts["Category"]
            let exists = categoryText.waitForExistence(timeout: 3.0) || app.navigationBars.element.waitForExistence(timeout: 3.0)
            XCTAssertTrue(exists, "Navigating to Categories tab should show categories content")
        }
    }
    
    func testNavigation_switchToSearchTab() {
        let tabBars = app.tabBars
        let searchTab = tabBars.buttons.element(boundBy: 2)
        
        if searchTab.waitForExistence(timeout: 3.0) {
            searchTab.tap()
            
            // Search view contains "search" placeholder or search bar
            let searchText = app.staticTexts["search"]
            let searchField = app.searchFields.element
            let exists = searchText.waitForExistence(timeout: 3.0) || searchField.waitForExistence(timeout: 3.0)
            XCTAssertTrue(exists, "Navigating to Search tab should show search content")
        }
    }
    
    func testNavigation_returnToMainTab() {
        let tabBars = app.tabBars
        let searchTab = tabBars.buttons.element(boundBy: 2)
        let mainTab = tabBars.buttons.element(boundBy: 1)
        
        if searchTab.waitForExistence(timeout: 3.0) {
            searchTab.tap()
        }
        
        if mainTab.waitForExistence(timeout: 3.0) {
            mainTab.tap()
            
            let weAreText = app.staticTexts["WE ARE"]
            let mainCategoriesText = app.staticTexts["MAIN CATEGORIES"]
            XCTAssertTrue(weAreText.waitForExistence(timeout: 3.0) || mainCategoriesText.waitForExistence(timeout: 3.0),
                          "Switching back to Main tab should display main view content")
        }
    }
    
    func testNavigation_reselectCurrentTab_preservesStability() {
        let tabBars = app.tabBars
        let mainTab = tabBars.buttons.element(boundBy: 1)
        
        if mainTab.waitForExistence(timeout: 3.0) {
            // Re-tap current active tab
            mainTab.tap()
            mainTab.tap()
            
            // App should remain stable and responsive
            let exists = app.staticTexts["MAIN CATEGORIES"].waitForExistence(timeout: 3.0) || app.staticTexts["WE ARE"].waitForExistence(timeout: 3.0)
            XCTAssertTrue(exists, "App must remain stable after reselecting active tab")
        }
    }
    
    func testNavigation_cycleAllTabsSequentially() {
        let tabBars = app.tabBars
        guard tabBars.element.waitForExistence(timeout: 3.0) else { return }
        
        let tabCount = tabBars.buttons.count
        XCTAssertGreaterThanOrEqual(tabCount, 3, "Expected at least 3 tabs in navigation bar")
        
        for index in 0..<tabCount {
            let tab = tabBars.buttons.element(boundBy: index)
            tab.tap()
            // Short pause to allow view transition
            _ = app.wait(for: .runningForeground, timeout: 1.0)
        }
        
        // Return to main tab
        let mainTab = tabBars.buttons.element(boundBy: 1)
        mainTab.tap()
        XCTAssertTrue(app.staticTexts["MAIN CATEGORIES"].waitForExistence(timeout: 3.0) || app.staticTexts["WE ARE"].waitForExistence(timeout: 3.0))
    }
}
