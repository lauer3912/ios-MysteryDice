import SwiftUI
import Combine

@MainActor
class GameManager: ObservableObject {
    @Published var allCases: [Case] = []
    @Published var progress: DetectiveProgress = DetectiveProgress()
    @Published var todayCase: Case?
    @Published var activeCase: Case?
    @Published var collectedEvidence: [Evidence] = []
    @Published var streak: Int = 0
    @Published var suspicionLevel: Double = 50
    
    private let userDefaults = UserDefaults.standard
    private let casesKey = "mysterydice_cases"
    private let progressKey = "mysterydice_progress"
    private let streakKey = "mysterydice_streak"
    private let lastPlayedKey = "mysterydice_lastplayed"
    
    init() {
        loadData()
        generateCasesIfNeeded()
        checkDailyCase()
        checkStreak()
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        if let data = userDefaults.data(forKey: casesKey),
           let cases = try? JSONDecoder().decode([Case].self, from: data) {
            allCases = cases
        }
        
        if let data = userDefaults.data(forKey: progressKey),
           let savedProgress = try? JSONDecoder().decode(DetectiveProgress.self, from: data) {
            progress = savedProgress
        }
        
        streak = userDefaults.integer(forKey: streakKey)
    }
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(allCases) {
            userDefaults.set(data, forKey: casesKey)
        }
        
        if let data = try? JSONEncoder().encode(progress) {
            userDefaults.set(data, forKey: progressKey)
        }
        
        userDefaults.set(streak, forKey: streakKey)
    }
    
    // MARK: - Case Generation
    
    private func generateCasesIfNeeded() {
        guard allCases.isEmpty else { return }
        
        allCases = [
            createOfficeMurderCase(),
            createMansionMysteryCase(),
            createHospitalKillingCase(),
            createRestaurantPoisoningCase(),
            createMuseumHeistCase(),
            createJewelryStoreRobberyCase(),
            createVanishedActressCase(),
            createMissingChildCase(),
            createColdCaseFileCase(),
            createSerialKillerCase()
        ]
        
        saveData()
    }
    
    private func createOfficeMurderCase() -> Case {
        let suspect1 = Suspect(
            id: UUID(),
            name: "John Manager",
            description: "The company manager. Had a heated argument with the victim last week about project delays.",
            age: 45,
            occupation: "Manager",
            isTheRealGuilty: true,
            alibi: "Was in a meeting from 6 PM to 8 PM",
            motive: "Financial disputes over project budget",
            opportunity: "Could access the conference room with his keycard",
            lieTruthScore: 35,
            avatarImageName: "person.fill",
            dialogues: [
                Dialogue(id: UUID(), text: "I was in the meeting the whole time!", isFromSuspect: true, isLie: true),
                Dialogue(id: UUID(), text: "The meeting ended at 7 PM, not 8 PM", isFromSuspect: false, isLie: false)
            ]
        )
        
        let suspect2 = Suspect(
            id: UUID(),
            name: "Sarah Secretary",
            description: "The victim's secretary. Recently passed for a promotion the victim got instead.",
            age: 28,
            occupation: "Secretary",
            isTheRealGuilty: false,
            alibi: "Left office at 6 PM to pick up her child",
            motive: "Passed over for promotion",
            opportunity: "Had access to the conference room",
            lieTruthScore: 70,
            avatarImageName: "person.fill",
            dialogues: [
                Dialogue(id: UUID(), text: "I left early, I have witnesses!", isFromSuspect: true, isLie: false)
            ]
        )
        
        let suspect3 = Suspect(
            id: UUID(),
            name: "Mike IT Guy",
            description: "IT support. Was seen arguing with the victim about a server outage.",
            age: 32,
            occupation: "IT Specialist",
            isTheRealGuilty: false,
            alibi: "Was fixing servers in the basement",
            motive: "Verbal confrontation about server issues",
            opportunity: "Could manipulate security footage",
            lieTruthScore: 55,
            avatarImageName: "person.fill",
            dialogues: [
                Dialogue(id: UUID(), text: "The server was down, everyone saw it", isFromSuspect: true, isLie: true)
            ]
        )
        
        let evidence1 = Evidence(
            id: UUID(),
            name: "Bloody Keycard",
            description: "A keycard found near the body with blood stains",
            type: .weapon,
            imageName: "key.fill",
            collectedAt: nil,
            isCollected: false,
            verifiedInfo: "Belongs to John Manager",
            linkedToSuspectId: suspect1.id
        )
        
        let evidence2 = Evidence(
            id: UUID(),
            name: "Security Footage",
            description: "Edited security footage showing incomplete timeline",
            type: .digital,
            imageName: "video.fill",
            collectedAt: nil,
            isCollected: false,
            verifiedInfo: "Missing 30 minutes of footage",
            linkedToSuspectId: suspect3.id
        )
        
        let evidence3 = Evidence(
            id: UUID(),
            name: "Fingerprints",
            description: "Partial fingerprints on the door handle",
            type: .fingerprint,
            imageName: "hand.point.up.fill",
            collectedAt: nil,
            isCollected: false,
            verifiedInfo: "Match John Manager",
            linkedToSuspectId: suspect1.id
        )
        
        let node1 = StoryNode(
            id: UUID(),
            description: "The victim, a senior developer, was found lifeless in the conference room. No signs of forced entry. The door was unlocked.",
            sceneImageName: "conference_room",
            choices: [
                Choice(id: UUID(), text: "Examine the body", nextNodeId: UUID(), hint: "Look for physical evidence", addsEvidence: [evidence3.id], requiresEvidence: nil),
                Choice(id: UUID(), text: "Check the security cameras", nextNodeId: UUID(), hint: "Review footage", addsEvidence: [evidence2.id], requiresEvidence: nil),
                Choice(id: UUID(), text: "Interview the suspects", nextNodeId: UUID(), hint: "Start interrogation", requiresEvidence: nil)
            ],
            evidenceRequired: [],
            isEnding: false
        )
        
        let ending1 = Ending(
            id: UUID(),
            title: "Case Solved - Correct Suspect",
            description: "You correctly identified John Manager as the murderer. He was arrested and convicted.",
            type: .solved,
            isBestEnding: true,
            rating: 5
        )
        
        let ending2 = Ending(
            id: UUID(),
            title: "Wrong Person Convicted",
            description: "You accused the wrong person. Sarah was convicted but later proved innocent when John escaped.",
            type: .wrongPerson,
            isBestEnding: false,
            rating: 1
        )
        
        return Case(
            title: "The Office Murder",
            description: "A senior developer was found dead in the conference room. Three suspects, one killer.",
            category: .murder,
            difficulty: 3,
            briefingText: "The victim was found in the conference room at 9 PM. No forced entry was detected. Three employees had motive and opportunity.",
            suspects: [suspect1, suspect2, suspect3],
            evidence: [evidence1, evidence2, evidence3],
            storyNodes: [node1],
            endings: [ending1, ending2]
        )
    }
    
    private func createMansionMysteryCase() -> Case {
        let suspect1 = Suspect(
            id: UUID(),
            name: "Lady Victoria",
            description: "The mansion owner's daughter. She recently changed the will.",
            age: 34,
            occupation: "Socialite",
            isTheRealGuilty: false,
            alibi: "Was at a charity event",
            motive: "Inheritance dispute",
            opportunity: "Has master key to all rooms",
            lieTruthScore: 60,
            avatarImageName: "person.fill",
            dialogues: []
        )
        
        return Case(
            title: "Mansion Mystery",
            description: "The wealthy owner of a mansion is found dead in his study. Family secrets run deep.",
            category: .murder,
            difficulty: 4,
            briefingText: "Sir William was found dead in his private study. The mansion was full of guests during a party.",
            suspects: [suspect1],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createHospitalKillingCase() -> Case {
        Case(
            title: "Hospital Killing",
            description: "A patient dies mysteriously in a private hospital. Was it murder or negligence?",
            category: .murder,
            difficulty: 4,
            briefingText: "Patient in room 408 died under suspicious circumstances. Staff had varying access.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createRestaurantPoisoningCase() -> Case {
        Case(
            title: "Restaurant Poisoning",
            description: "A famous food critic dies after dining at an elite restaurant. Who poisoned him?",
            category: .murder,
            difficulty: 3,
            briefingText: "The critic collapsed after finishing his meal. Restaurant staff are the only suspects.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createMuseumHeistCase() -> Case {
        Case(
            title: "Museum Heist",
            description: "A priceless diamond disappears from a secure museum. Inside job or external?",
            category: .theft,
            difficulty: 4,
            briefingText: "The diamond vanished from a locked display case. Only three people had the key.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createJewelryStoreRobberyCase() -> Case {
        Case(
            title: "Jewelry Store Robbery",
            description: "An elaborate heist at a high-end jewelry store. The robbers knew exactly what they wanted.",
            category: .theft,
            difficulty: 3,
            briefingText: "Armed robbers took only specific items. Security footage shows unusual expertise.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createVanishedActressCase() -> Case {
        Case(
            title: "Vanished Actress",
            description: "A rising star disappears on the night before her big break. Kidnapping or voluntary?",
            category: .missing,
            difficulty: 5,
            briefingText: "The actress was last seen leaving her apartment. No ransom demand was made.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createMissingChildCase() -> Case {
        Case(
            title: "Missing Child",
            description: "A child disappears from a busy mall. Security cameras show nothing. Where is the child?",
            category: .missing,
            difficulty: 5,
            briefingText: "A 7-year-old vanished from the toy section. Witnesses saw nothing unusual.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createColdCaseFileCase() -> Case {
        Case(
            title: "Cold Case Files",
            description: "A 20-year-old murder case suddenly has new evidence. Can you solve it now?",
            category: .special,
            difficulty: 5,
            briefingText: "Detective, we reopened this case. New DNA evidence has surfaced. Time to crack it.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    private func createSerialKillerCase() -> Case {
        Case(
            title: "The Serial Killer",
            description: "Bodies are found with a signature. A serial killer is on the loose. Can you catch him?",
            category: .special,
            difficulty: 5,
            briefingText: "Three victims, same signature at each scene. The killer is getting bolder.",
            suspects: [],
            evidence: [],
            storyNodes: [],
            endings: []
        )
    }
    
    // MARK: - Daily Case
    
    private func checkDailyCase() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find unlocked case for today
        let unlockedCases = allCases.filter { $0.unlockedAt != nil && !$0.isCompleted }
        if let nextCase = unlockedCases.first {
            todayCase = nextCase
            activeCase = nextCase
        } else {
            // Check if all completed
            let completedCount = allCases.filter { $0.isCompleted }.count
            if completedCount == allCases.count {
                todayCase = nil
            } else {
                // Unlock next case
                if let nextToUnlock = allCases.first(where: { $0.unlockedAt == nil }) {
                    nextToUnlock.unlockedAt = today
                    todayCase = nextToUnlock
                    activeCase = nextToUnlock
                    saveData()
                }
            }
        }
    }
    
    // MARK: - Streak
    
    private func checkStreak() {
        let lastPlayed = userDefaults.object(forKey: lastPlayedKey) as? Date ?? Date.distantPast
        let calendar = Calendar.current
        
        if calendar.isDateInYesterday(lastPlayed) {
            // Continue streak
        } else if !calendar.isDateInToday(lastPlayed) {
            // Reset streak
            streak = 0
        }
        
        userDefaults.set(Date(), forKey: lastPlayedKey)
    }
    
    // MARK: - Actions
    
    func completeCase(_ caseItem: Case, ending: Ending) {
        if let index = allCases.firstIndex(where: { $0.id == caseItem.id }) {
            allCases[index].isCompleted = true
            allCases[index].selectedEndingId = ending.id
        }
        
        if ending.isBestEnding {
            progress.reputationPoints += 50
            progress.statistics.totalCorrectEndings += 1
            streak += 1
        } else {
            progress.reputationPoints += 10
            progress.statistics.totalWrongEndings += 1
            streak = 0
        }
        
        progress.totalCasesCompleted += 1
        updateRank()
        saveData()
    }
    
    private func updateRank() {
        for rank in DetectiveRank.allCases.reversed() {
            if progress.reputationPoints >= rank.requiredPoints {
                progress.rank = rank
                break
            }
        }
    }
    
    func saveProgress() {
        saveData()
    }
    
    func resetProgress() {
        progress = DetectiveProgress()
        streak = 0
        allCases.removeAll()
        collectedEvidence.removeAll()
        generateCasesIfNeeded()
        checkDailyCase()
    }
    
    func exportData() {
        // Export game data to JSON
    }
}