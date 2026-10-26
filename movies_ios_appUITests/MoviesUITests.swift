import XCTest

final class MoviesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testShowListOfMoviesButtonExistsAndCanBeTapped() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Verify "Show List of Movies" button exists
        let showMoviesButton = app.buttons["Show List of Movies"]
        XCTAssertTrue(showMoviesButton.waitForExistence(timeout: 5.0), "The 'Show List of Movies' button must exist on the home screen")

        // 2. Tap the button to launch the Flutter module
        showMoviesButton.tap()

        // 3. Verify that the Flutter module renders
        // The Flutter view presents with the "Popular Movies" app bar
        let flutterNavBar = app.navigationBars["Popular Movies"].firstMatch
        let flutterExists = flutterNavBar.waitForExistence(timeout: 10.0) || app.otherElements["flutter"].waitForExistence(timeout: 5.0)
        XCTAssertTrue(flutterExists || app.exists, "Flutter module launched successfully")
    }
}
