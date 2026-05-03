import XCTest

final class ScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        Thread.sleep(forTimeInterval: 2.0)
    }
    
    // iPhone 16 Pro Max - 5 tabs
    func testiPhone_69_01_Home() throws {
        takeScreenshot(name: "01_Home", identifier: "tab_home")
    }
    
    func testiPhone_69_02_Cases() throws {
        tapTab(identifier: "tab_cases")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "02_Cases", identifier: "tab_cases")
    }
    
    func testiPhone_69_03_Evidence() throws {
        tapTab(identifier: "tab_evidence")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "03_Evidence", identifier: "tab_evidence")
    }
    
    func testiPhone_69_04_Stats() throws {
        tapTab(identifier: "tab_stats")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "04_Stats", identifier: "tab_stats")
    }
    
    func testiPhone_69_05_Settings() throws {
        tapTab(identifier: "tab_settings")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "05_Settings", identifier: "tab_settings")
    }
    
    // iPad Pro 13" - 5 tabs
    func testiPad_13_01_Home() throws {
        takeScreenshot(name: "01_Home", identifier: "tab_home")
    }
    
    func testiPad_13_02_Cases() throws {
        tapTab(identifier: "tab_cases")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "02_Cases", identifier: "tab_cases")
    }
    
    func testiPad_13_03_Evidence() throws {
        tapTab(identifier: "tab_evidence")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "03_Evidence", identifier: "tab_evidence")
    }
    
    func testiPad_13_04_Stats() throws {
        tapTab(identifier: "tab_stats")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "04_Stats", identifier: "tab_stats")
    }
    
    func testiPad_13_05_Settings() throws {
        tapTab(identifier: "tab_settings")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "05_Settings", identifier: "tab_settings")
    }
    
    // MARK: - Helper Functions
    
    private func tapTab(identifier: String) {
        let tabButton = app.buttons[identifier].firstMatch
        if tabButton.exists {
            tabButton.tap()
        } else {
            // Fallback: try tapping by label
            let label = identifier.replacingOccurrences(of: "tab_", with: "")
            app.buttons[label].tap()
        }
    }
    
    private func takeScreenshot(name: String, identifier: String) {
        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}