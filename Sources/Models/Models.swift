import Foundation

struct Case: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: CaseCategory
    var difficulty: Int
    var sceneImageName: String
    var briefingText: String
    var suspects: [Suspect]
    var evidence: [Evidence]
    var storyNodes: [StoryNode]
    var endings: [Ending]
    var currentNodeId: UUID?
    var isCompleted: Bool
    var selectedEndingId: UUID?
    var collectedEvidenceIds: [UUID]
    var unlockedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: CaseCategory,
        difficulty: Int,
        sceneImageName: String = "case_scene",
        briefingText: String,
        suspects: [Suspect],
        evidence: [Evidence],
        storyNodes: [StoryNode],
        endings: [Ending]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.sceneImageName = sceneImageName
        self.briefingText = briefingText
        self.suspects = suspects
        self.evidence = evidence
        self.storyNodes = storyNodes
        self.endings = endings
        self.currentNodeId = storyNodes.first?.id
        self.isCompleted = false
        self.collectedEvidenceIds = []
        self.unlockedAt = nil
    }
}

enum CaseCategory: String, Codable, CaseIterable {
    case murder = "Murder"
    case theft = "Theft"
    case missing = "Missing Person"
    case special = "Special"
    
    var iconName: String {
        switch self {
        case .murder: return "eye"
        case .theft: return "lock.open"
        case .missing: return "person.fill.questionmark"
        case .special: return "staroflife.fill"
        }
    }
    
    var color: String {
        switch self {
        case .murder: return "C0392B"
        case .theft: return "F39C12"
        case .missing: return "3498DB"
        case .special: return "9B59B6"
        }
    }
}

struct Suspect: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var age: Int
    var occupation: String
    var isTheRealGuilty: Bool
    var alibi: String
    var motive: String
    var opportunity: String
    var lieTruthScore: Int
    var avatarImageName: String
    var dialogues: [Dialogue]
}

struct Evidence: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var type: EvidenceType
    var imageName: String
    var collectedAt: Date?
    var isCollected: Bool
    var verifiedInfo: String
    var linkedToSuspectId: UUID?
}

enum EvidenceType: String, Codable, CaseIterable {
    case fingerprint = "Fingerprint"
    case photo = "Photo"
    case document = "Document"
    case weapon = "Weapon"
    case digital = "Digital"
    case testimonial = "Testimony"
    
    var iconName: String {
        switch self {
        case .fingerprint: return "hand.point.up.fill"
        case .photo: return "camera.fill"
        case .document: return "doc.fill"
        case .weapon: return "hammer.fill"
        case .digital: return "iphone"
        case .testimonial: return "quote.bubble.fill"
        }
    }
}

struct StoryNode: Identifiable, Codable {
    let id: UUID
    var description: String
    var sceneImageName: String?
    var choices: [Choice]
    var evidenceRequired: [UUID]
    var isEnding: Bool
}

struct Choice: Identifiable, Codable {
    let id: UUID
    var text: String
    var nextNodeId: UUID
    var hint: String?
    var addsEvidence: [UUID]?
    var requiresEvidence: [UUID]?
}

struct Ending: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var type: EndingType
    var isBestEnding: Bool
    var rating: Int
}

enum EndingType: String, Codable {
    case solved = "Case Solved"
    case wrongPerson = "Wrong Person"
    case unsolved = "Unsolved"
    case suspectEscaped = "Suspect Escaped"
    case playerDied = "Player Died"
}

struct Dialogue: Identifiable, Codable {
    let id: UUID
    var text: String
    var isFromSuspect: Bool
    var isLie: Bool
}

struct DetectiveStats: Codable {
    var totalPlayTime: TimeInterval = 0
    var averageSolveTime: TimeInterval = 0
    var bestTime: TimeInterval = 0
    var totalCorrectEndings: Int = 0
    var totalWrongEndings: Int = 0
    var evidenceCollected: Int = 0
    var suspectsInterrogated: Int = 0
}

struct DetectiveProgress: Codable {
    var rank: DetectiveRank = .rookie
    var reputationPoints: Int = 0
    var totalCasesCompleted: Int = 0
    var casesByEnding: [UUID: UUID] = [:]
    var unlockedSkills: [Skill] = []
    var achievements: [Achievement] = []
    var statistics: DetectiveStats = DetectiveStats()
}

enum DetectiveRank: String, Codable, CaseIterable {
    case rookie = "Rookie"
    case junior = "Junior"
    case detective = "Detective"
    case senior = "Senior"
    case master = "Master"
    
    var requiredPoints: Int {
        switch self {
        case .rookie: return 0
        case .junior: return 100
        case .detective: return 300
        case .senior: return 600
        case .master: return 1000
        }
    }
    
    var iconName: String {
        switch self {
        case .rookie: return "star"
        case .junior: return "star.leadinghalf.filled"
        case .detective: return "star.fill"
        case .senior: return "star.circle.fill"
        case .master: return "crown.fill"
        }
    }
}

struct Skill: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String = ""
    var description: String = ""
    var iconName: String = "star"
    var isUnlocked: Bool = false
}

struct Achievement: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String = ""
    var description: String = ""
    var iconName: String = "star"
    var isUnlocked: Bool = false
    var unlockedAt: Date? = nil
}