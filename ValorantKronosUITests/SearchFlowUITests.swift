//
//  SearchFlowUITests.swift
//  ValorantKronosUITests
//

import XCTest

final class SearchFlowUITests: XCTestCase {
    
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
    
    private func navigateToSearchTab() {
        let tabBars = app.tabBars
        let searchTab = tabBars.buttons.element(boundBy: 2)
        if searchTab.waitForExistence(timeout: 4.0) {
            searchTab.tap()
        }
    }
    
    // MARK: - Flow Tests
    
    func testSearchFlow_navigateToSearchTab() {
        navigateToSearchTab()
        
        let searchText = app.staticTexts["search"]
        let searchField = app.searchFields.element
        let exists = searchText.waitForExistence(timeout: 4.0) || searchField.waitForExistence(timeout: 4.0)
        XCTAssertTrue(exists, "Search screen should be presented upon tapping Search tab")
    }
    
    func testSearchFlow_searchBarTextEntry_andQueryExecution() {
        navigateToSearchTab()
        
        // If a search field exists on screen, enter query
        let searchField = app.searchFields.element
        if searchField.waitForExistence(timeout: 3.0) {
            searchField.tap()
            searchField.typeText("Sova")
            
            // Allow search filter to process
            _ = app.wait(for: .runningForeground, timeout: 1.0)
            
            // Verify typed query exists in search field
            XCTAssertEqual(searchField.value as? String, "Sova")
            
            // Clear text
            let clearButton = searchField.buttons["Clear text"]
            if clearButton.exists {
                clearButton.tap()
            }
        }
    }
    
    func testSearchFlow_resultTapping_interaction() {
        navigateToSearchTab()
        
        // Look for searchable list items or buttons
        let firstResult = app.buttons.element(boundBy: 0)
        if firstResult.waitForExistence(timeout: 3.0) {
            firstResult.tap()
            _ = app.wait(for: .runningForeground, timeout: 0.5)
        }
    }
    
    func testSearchFlow_tabSwitchingPreservesStability() {
        navigateToSearchTab()
        
        let tabBars = app.tabBars
        let mainTab = tabBars.buttons.element(boundBy: 1)
        let searchTab = tabBars.buttons.element(boundBy: 2)
        
        if mainTab.waitForExistence(timeout: 3.0) {
            mainTab.tap()
            _ = app.wait(for: .runningForeground, timeout: 0.5)
        }
        
        if searchTab.waitForExistence(timeout: 3.0) {
            searchTab.tap()
            _ = app.wait(for: .runningForeground, timeout: 0.5)
            
            let searchText = app.staticTexts["search"]
            let searchField = app.searchFields.element
            let exists = searchText.waitForExistence(timeout: 3.0) || searchField.waitForExistence(timeout: 3.0)
            XCTAssertTrue(exists, "Search tab should remain accessible after tab switching")
        }
    }
}
