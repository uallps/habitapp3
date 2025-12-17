import XCTest

class AppLauncherHelper {
    
    // Launches the app and asserts that a given button exists
    static func launchAppA() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }
}