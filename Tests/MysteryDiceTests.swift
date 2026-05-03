import XCTest
@testable import MysteryDice

final class MysteryDiceTests: XCTestCase {
    
    func testCaseCreation() {
        let caseItem = Case(
            title: "Test Case",
            description: "Test description",
            category: .murder,
            difficulty: 3,
            briefingText: "Test briefing",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
        
        XCTAssertEqual(caseItem.title, "Test Case")
        XCTAssertEqual(caseItem.category, .murder)
        XCTAssertEqual(caseItem.difficulty, 3)
        XCTAssertFalse(caseItem.isCompleted)
    }
    
    func testEvidenceCollection() {
        var evidence = Evidence(
            id: UUID(),
            name: "Test Evidence",
            description: "Test",
            type: .fingerprint,
            imageName: "test",
            collectedAt: nil,
            isCollected: false,
            verifiedInfo: ""
        )
        
        XCTAssertFalse(evidence.isCollected)
        
        evidence.isCollected = true
        evidence.collectedAt = Date()
        
        XCTAssertTrue(evidence.isCollected)
        XCTAssertNotNil(evidence.collectedAt)
    }
    
    func testDetectiveRank() {
        var progress = DetectiveProgress()
        
        XCTAssertEqual(progress.rank, .rookie)
        
        progress.reputationPoints = 150
        XCTAssertEqual(progress.rank, .junior)
        
        progress.reputationPoints = 350
        XCTAssertEqual(progress.rank, .detective)
    }
}