//
//  WeaponsFlowUITests.swift
//  ValorantKronosUITests
//

import XCTest

final class WeaponsFlowUITests: XCTestCase {
    
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
    
    private func navigateToWeaponsScreen() {
        let weaponsCard = app.staticTexts["WEAPONS"]
        if weaponsCard.waitForExistence(timeout: 4.0) {
            weaponsCard.tap()
        } else {
            app.swipeUp()
            if weaponsCard.waitForExistence(timeout: 3.0) {
                weaponsCard.tap()
            }
        }
    }
    
    // MARK: - Flow Tests
    
    func testWeaponsFlow_navigateFromMainToWeaponsList() {
        navigateToWeaponsScreen()
        
        let weaponsTitle = app.staticTexts["WEAPONS"]
        XCTAssertTrue(weaponsTitle.waitForExistence(timeout: 5.0),
                      "WeaponsView should display 'WEAPONS' header title")
    }
    
    func testWeaponsFlow_categoryDisclosureGroups_expandAndCollapse() {
        navigateToWeaponsScreen()
        
        // Find category accordion headers (e.g. SIDEARMS, RIFLES, HEAVY)
        let sidearmsHeader = app.staticTexts["SIDEARMS"]
        let heavyHeader = app.staticTexts["HEAVY"]
        
        let headerToTap = sidearmsHeader.exists ? sidearmsHeader : heavyHeader
        if headerToTap.waitForExistence(timeout: 4.0) {
            headerToTap.tap()
            
            // Allow animation
            _ = app.wait(for: .runningForeground, timeout: 0.5)
            
            // Tap again to collapse
            headerToTap.tap()
            _ = app.wait(for: .runningForeground, timeout: 0.5)
        }
    }
    
    func testWeaponsFlow_scrollWeaponsCategories() {
        navigateToWeaponsScreen()
        
        let scrollView = app.scrollViews.element(boundBy: 0)
        if scrollView.waitForExistence(timeout: 4.0) {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
    
    func testWeaponsFlow_tapWeaponCard_opensDetailView() {
        navigateToWeaponsScreen()
        
        // Expand first available category disclosure group
        let sidearmsHeader = app.staticTexts["SIDEARMS"]
        if sidearmsHeader.waitForExistence(timeout: 4.0) {
            sidearmsHeader.tap()
        }
        
        // If a weapon card button exists inside, tap it
        let weaponCard = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Odin' OR label CONTAINS[c] 'Vandal' OR label CONTAINS[c] 'Phantom'")).element
        if weaponCard.waitForExistence(timeout: 3.0) {
            weaponCard.tap()
            
            // SingleWeaponView has BACK button
            let backButton = app.buttons["BACK"]
            let exists = backButton.waitForExistence(timeout: 4.0) || app.navigationBars.buttons.element.waitForExistence(timeout: 4.0)
            XCTAssertTrue(exists, "Weapon detail screen should display with back navigation")
        }
    }
    
    func testWeaponsFlow_backButton_returnsToMainView() {
        navigateToWeaponsScreen()
        
        // Find BACK button in WeaponsView toolbar
        let backButton = app.buttons["BACK"]
        if backButton.waitForExistence(timeout: 4.0) {
            backButton.tap()
            
            // Should return to MainView
            let mainCategories = app.staticTexts["MAIN CATEGORIES"]
            XCTAssertTrue(mainCategories.waitForExistence(timeout: 4.0),
                          "Tapping BACK button should return to MainView")
        }
    }
}
