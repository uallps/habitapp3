import XCTest

class CreateCategories: XCTestCase {

    func testCreateCategoriasiOS() {
        let app = Helper.launchAppAndAssertButtonExistence()
        
        // Assert that the login screen is visible
        XCTAssertTrue(app.buttons["Login"].exists)
        app.buttons["Categorías"].tap()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Categorías Tab iOS"
        attachment.lifetime = .keepAlways
        add(attachment)
        Helper.saveScreenshots("./screenshots/CategoriasTab_iOS.png")

}

    func testCreateCategoriasMac() {
        let app = Helper.launchAppAndAssertButtonExistence()

        XCTAssertTrue(app.staticTexts["Categorías"].exists)
        app.staticTexts["Categorías"].click()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Categorías Tab macOS"
        attachment.lifetime = .keepAlways
        add(attachment)
        Helper.saveScreenshots("./screenshots/CategoriasTab_Mac.png")
    }
}
