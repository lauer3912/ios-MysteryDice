import SwiftUI

struct CaseView: View {
    @EnvironmentObject var gameManager: GameManager
    @State var caseItem: Case
    @State private var currentNode: StoryNode?
    @State private var showEvidenceSheet = false
    @State private var showSuspectSheet = false
    @State private var timer: Int = 0
    @State private var isTimerRunning = false
    
    var body: some View {
        ZStack {
            Color("DarkNavy").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    caseHeaderSection
                    
                    if let node = currentNode ?? caseItem.storyNodes.first {
                        storyNodeSection(node)
                    }
                    
                    evidenceAndSuspectsSection
                    
                    if let node = currentNode, !node.isEnding {
                        choicesSection(node)
                    }
                }
                .padding(16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { gameManager.saveProgress(); goBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("AccentGold"))
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Case #\(caseIndex + 1)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if isTimerRunning {
                        Text(formatTime(timer))
                            .font(.caption.monospaced())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("AccentRed").opacity(0.8))
                            .cornerRadius(8)
                    }
                    
                    Button(action: { isTimerRunning.toggle() }) {
                        Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                            .foregroundColor(Color("AccentGold"))
                    }
                }
            }
        }
        .onAppear {
            currentNode = caseItem.storyNodes.first { $0.id == caseItem.currentNodeId }
            if caseItem.unlockedAt == nil {
                caseItem.unlockedAt = Date()
            }
            if isTimerRunning {
                startTimer()
            }
        }
    }
    
    private var caseIndex: Int {
        gameManager.allCases.firstIndex(where: { $0.id == caseItem.id }) ?? 0
    }
    
    private var caseHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: caseItem.category.iconName)
                    .foregroundColor(Color(hex: caseItem.category.color))
                
                Text(caseItem.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < caseItem.difficulty ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(i < caseItem.difficulty ? Color("AccentGold") : .gray)
                    }
                }
            }
            
            Text(caseItem.briefingText)
                .font(.body)
                .foregroundColor(.gray)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("CardDark"))
                .cornerRadius(12)
        }
    }
    
    private func storyNodeSection(_ node: StoryNode) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(node.description)
                .font(.body)
                .foregroundColor(.white)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("CardDark"))
                .cornerRadius(12)
            
            if let sceneName = node.sceneImageName {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                    
                    VStack {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text(sceneName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var evidenceAndSuspectsSection: some View {
        HStack(spacing: 12) {
            Button(action: { showEvidenceSheet = true }) {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2)
                    Text("Evidence")
                        .font(.caption)
                    Text("\(caseItem.collectedEvidenceIds.count)/\(caseItem.evidence.count)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color("CardDark"))
                .cornerRadius(12)
            }
            
            Button(action: { showSuspectSheet = true }) {
                VStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                    Text("Suspects")
                        .font(.caption)
                    Text("\(caseItem.suspects.count)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color("CardDark"))
                .cornerRadius(12)
            }
        }
        .sheet(isPresented: $showEvidenceSheet) {
            EvidenceCollectionSheet(caseItem: $caseItem)
        }
        .sheet(isPresented: $showSuspectSheet) {
            SuspectListSheet(caseItem: caseItem)
        }
    }
    
    private func choicesSection(_ node: StoryNode) -> some View {
        VStack(spacing: 12) {
            ForEach(node.choices) { choice in
                Button(action: { makeChoice(choice) }) {
                    HStack {
                        Text(choice.text)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("AccentGold"))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("AccentGold").opacity(0.5), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private func makeChoice(_ choice: Choice) {
        if let nextNode = caseItem.storyNodes.first(where: { $0.id == choice.nextNodeId }) {
            withAnimation {
                currentNode = nextNode
                caseItem.currentNodeId = nextNode.id
                
                if nextNode.isEnding {
                    caseItem.isCompleted = true
                    if let ending = caseItem.endings.first(where: { $0.id == choice.nextNodeId }) {
                        caseItem.selectedEndingId = ending.id
                        gameManager.completeCase(caseItem, ending: ending)
                    }
                }
                
                if let newEvidence = choice.addsEvidence {
                    for evidenceId in newEvidence {
                        if let index = caseItem.evidence.firstIndex(where: { $0.id == evidenceId }) {
                            caseItem.evidence[index].isCollected = true
                            caseItem.evidence[index].collectedAt = Date()
                            caseItem.collectedEvidenceIds.append(evidenceId)
                        }
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if isTimerRunning {
                timer += 1
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private func goBack() {
        // Navigation handled by toolbar
    }
}

struct EvidenceCollectionSheet: View {
    @Binding var caseItem: Case
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkNavy").ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(caseItem.evidence) { evidence in
                            EvidenceRowView(evidence: evidence, isCollected: caseItem.collectedEvidenceIds.contains(evidence.id))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Evidence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentGold"))
                }
            }
        }
    }
}

struct EvidenceRowView: View {
    let evidence: Evidence
    let isCollected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCollected ? Color("AccentGold").opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: evidence.type.iconName)
                    .font(.title2)
                    .foregroundColor(isCollected ? Color("AccentGold") : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(evidence.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(evidence.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isCollected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color("CardDark"))
        .cornerRadius(12)
        .opacity(isCollected ? 1 : 0.7)
    }
}

struct SuspectListSheet: View {
    let caseItem: Case
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkNavy").ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(caseItem.suspects) { suspect in
                            SuspectCardView(suspect: suspect)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Suspects")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentGold"))
                }
            }
        }
    }
}

struct SuspectCardView: View {
    let suspect: Suspect
    @State private var showDialogue = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suspect.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(suspect.occupation)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Text("\(suspect.age) years old")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        if suspect.lieTruthScore < 50 {
                            Text("LIAR")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("AccentRed"))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Text(suspect.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Button(action: { showDialogue.toggle() }) {
                Text("Interrogate")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("AccentGold"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("AccentGold").opacity(0.2))
                    .cornerRadius(8)
            }
            
            if showDialogue {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(suspect.dialogues) { dialogue in
                        HStack(alignment: .top) {
                            if dialogue.isFromSuspect {
                                Text(suspect.name)
                                    .font(.caption.bold())
                                    .foregroundColor(Color("AccentGold"))
                            }
                            
                            Text(dialogue.text)
                                .font(.body)
                                .foregroundColor(dialogue.isLie ? Color("AccentRed") : .white)
                            
                            Spacer()
                            
                            if dialogue.isLie {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color("AccentRed"))
                                    .font(.caption)
                            }
                        }
                        .padding(12)
                        .background(Color("CardDark"))
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color("CardDark").opacity(0.8))
        .cornerRadius(12)
    }
}

#Preview {
    CaseView(caseItem: Case(
        title: "The Office Murder",
        description: "A body was found in the conference room",
        category: .murder,
        difficulty: 3,
        briefingText: "The victim was found in the conference room at 9 PM. No forced entry.",
        suspects: [],
        evidence: [],
        storyNodes: [],
        endings: []
    ))
    .environmentObject(GameManager())
}