import XCTest

class CreateCategories: XCTestCase {

    func testCreateCategoriasiOS() {
        let app = AppLauncher.launchAppAndAssertButtonExistence()
        
        // Assert that the login screen is visible
        XCTAssertTrue(app.buttons["Login"].exists)
        app.buttons["Categorías"].tap()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Categorías Tab iOS"
        attachment.lifetime = .keepAlways
        add(attachment)


}

    func testCreateCategoriasMac() {
        let app = AppLauncher.launchAppAndAssertButtonExistence()

        XCTAssertTrue(app.staticTexts["Categorías"].exists)
        app.staticTexts["Categorías"].click()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Categorías Tab macOS"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
