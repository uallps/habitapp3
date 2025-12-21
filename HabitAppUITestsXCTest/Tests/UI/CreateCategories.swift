import XCTest

class CreateCategories: XCTestCase {

    func testCreateCategoriasiOS() {
        let app = Helper.launchApp()
        
        // Assert that the login screen is visible
        XCTAssertTrue(app.buttons["Login"].exists)
        app.buttons["Categorías"].tap()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Categorías Tab iOS"
        attachment.lifetime = .keepAlways
        add(attachment)
        Helper.saveScreenshots(path: "./screenshots/CategoriasTab_iOS.png")

}

    func testCreateCategoriasMac() {
        let app = Helper.launchApp()

        XCTAssertTrue(app.staticTexts["Categorías"].exists)
        app.staticTexts["Categorías"].click()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Categorías Tab macOS"
        attachment.lifetime = .keepAlways
        add(attachment)
        Helper.saveScreenshots(path: "./screenshots/CategoriasTab_Mac.png")
    }
}
