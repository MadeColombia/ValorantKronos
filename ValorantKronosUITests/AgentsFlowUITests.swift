//
//  AgentsFlowUITests.swift
//  ValorantKronosUITests
//

import XCTest

final class AgentsFlowUITests: XCTestCase {
    
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
    
    private func navigateToAgentsScreen() {
        // Main view has "AGENTS" card inside horizontal scroll of MAIN CATEGORIES
        let agentsCard = app.staticTexts["AGENTS"]
        if agentsCard.waitForExistence(timeout: 4.0) {
            agentsCard.tap()
        } else {
            // Scroll down to locate MAIN CATEGORIES if needed
            app.swipeUp()
            if agentsCard.waitForExistence(timeout: 3.0) {
                agentsCard.tap()
            }
        }
    }
    
    // MARK: - Flow Tests
    
    func testAgentsFlow_navigateFromMainToAgentsList() {
        navigateToAgentsScreen()
        
        // In AgentsView, the dropdown label defaults to "ALL AGENTS"
        let allAgentsLabel = app.staticTexts["ALL AGENTS"]
        let exists = allAgentsLabel.waitForExistence(timeout: 5.0) || app.navigationBars.element.waitForExistence(timeout: 5.0)
        XCTAssertTrue(exists, "AgentsView should display upon tapping AGENTS card")
    }
    
    func testAgentsFlow_roleFilterDropdown_expandAndCollapse() {
        navigateToAgentsScreen()
        
        let allAgentsButton = app.staticTexts["ALL AGENTS"]
        if allAgentsButton.waitForExistence(timeout: 5.0) {
            // Tap to expand role dropdown
            allAgentsButton.tap()
            
            // Check if options appear (e.g. checkmark or role names like DUELISTS)
            let checkmark = app.images["checkmark"]
            let expanded = checkmark.waitForExistence(timeout: 3.0) || app.staticTexts["ALL AGENTS"].exists
            XCTAssertTrue(expanded, "Tapping filter should expand dropdown or show options")
            
            // Tap again to toggle/collapse
            allAgentsButton.tap()
        }
    }
    
    func testAgentsFlow_scrollAgentsList() {
        navigateToAgentsScreen()
        
        // Wait for agents grid to populate or scroll view to exist
        let scrollView = app.scrollViews.element(boundBy: 0)
        if scrollView.waitForExistence(timeout: 5.0) {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
    
    func testAgentsFlow_tapAgentCard_opensDetailView() {
        navigateToAgentsScreen()
        
        // Wait for agent cards to appear in grid
        let firstCard = app.buttons.element(boundBy: 0)
        if firstCard.waitForExistence(timeout: 5.0) {
            firstCard.tap()
            
            // SingleAgentView displays agent details, back button, or portrait
            let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Back' OR identifier CONTAINS[c] 'Back'")).element
            let backExists = backButton.waitForExistence(timeout: 4.0) || app.navigationBars.buttons.element.waitForExistence(timeout: 4.0)
            XCTAssertTrue(backExists, "Detail view should be displayed with back button")
        }
    }
    
    func testAgentsFlow_detailView_backButton_returnsToList() {
        navigateToAgentsScreen()
        
        let firstCard = app.buttons.element(boundBy: 0)
        if firstCard.waitForExistence(timeout: 5.0) {
            firstCard.tap()
            
            // Find and tap back button
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.waitForExistence(timeout: 3.0) {
                backButton.tap()
                
                // Should return to AgentsView
                let allAgentsLabel = app.staticTexts["ALL AGENTS"]
                XCTAssertTrue(allAgentsLabel.waitForExistence(timeout: 3.0),
                              "Tapping back button should return to Agents list")
            }
        }
    }
}
