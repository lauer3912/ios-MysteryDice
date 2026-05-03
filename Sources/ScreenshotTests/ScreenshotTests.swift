import XCTest

final class ScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        Thread.sleep(forTimeInterval: 3.0)
    }
    
    // iPhone 16 Pro Max - 5 tabs
    func testiPhone_69_01_Home() throws {
        takeScreenshot(name: "01_Home")
    }
    
    func testiPhone_69_02_Cases() throws {
        tapTabByLabel("Cases")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "02_Cases")
    }
    
    func testiPhone_69_03_Evidence() throws {
        tapTabByLabel("Evidence")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "03_Evidence")
    }
    
    func testiPhone_69_04_Stats() throws {
        tapTabByLabel("Stats")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "04_Stats")
    }
    
    func testiPhone_69_05_Settings() throws {
        tapTabByLabel("Settings")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "05_Settings")
    }
    
    // iPad Pro 13" - 5 tabs
    func testiPad_13_01_Home() throws {
        takeScreenshot(name: "01_Home")
    }
    
    func testiPad_13_02_Cases() throws {
        tapTabByLabel("Cases")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "02_Cases")
    }
    
    func testiPad_13_03_Evidence() throws {
        tapTabByLabel("Evidence")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "03_Evidence")
    }
    
    func testiPad_13_04_Stats() throws {
        tapTabByLabel("Stats")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "04_Stats")
    }
    
    func testiPad_13_05_Settings() throws {
        tapTabByLabel("Settings")
        Thread.sleep(forTimeInterval: 1.5)
        takeScreenshot(name: "05_Settings")
    }
    
    // MARK: - Helper Functions
    
    private func tapTabByLabel(_ label: String) {
        // Wait for tab to be tappable
        let tabButton = app.buttons[label]
        if tabButton.waitForExistence(timeout: 5) {
            tabButton.tap()
        } else {
            XCTFail("Tab button '\(label)' not found")
        }
    }
    
    private func takeScreenshot(name: String) {
        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}