import XCTest

class Helper {
    
    // Launches the app and asserts that a given button exists
    static func launchAppA() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    // Saves screenshots to screenshots folder. Asummes screenshots folder exists.
    static func saveScreenshots(path: String) {
        let screenshotFileURL = URL(fileURLWithPath: path)
        try? screenshot.pngRepresentation.write(to: screenshotFileURL)
    }
}