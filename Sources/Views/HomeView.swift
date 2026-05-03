import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showingCase = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    if let todayCase = gameManager.todayCase {
                        todaysCaseSection(todayCase)
                    } else {
                        noCaseSection
                    }
                    
                    progressSection
                    
                    evidencePreviewSection
                    
                    startInvestigationButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color("DarkNavy"))
            .navigationDestination(isPresented: $showingCase) {
                if let caseItem = gameManager.todayCase {
                    CaseView(caseItem: caseItem)
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("MysteryDice")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("AccentGold"))
                
                Text(todayDateString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell.fill")
                    .foregroundColor(Color("AccentGold"))
                    .font(.title2)
            }
        }
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    private func todaysCaseSection(_ caseItem: Case) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Case")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("NEW")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("AccentRed"))
                    .clipShape(Capsule())
            }
            
            NavigationLink(destination: CaseView(caseItem: caseItem)) {
                CaseCardView(caseItem: caseItem)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var noCaseSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color("AccentGold"))
            
            Text("All Cases Completed!")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Come back tomorrow for a new mystery")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color("CardDark"))
        .cornerRadius(16)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Solved",
                    value: "\(gameManager.progress.totalCasesCompleted)",
                    icon: "checkmark.seal.fill",
                    color: Color("AccentGold")
                )
                
                StatCard(
                    title: "Rank",
                    value: gameManager.progress.rank.rawValue,
                    icon: gameManager.progress.rank.iconName,
                    color: Color("AccentRed")
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(gameManager.streak) days",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var evidencePreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Evidence Board")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: EvidenceBoardView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(Color("AccentGold"))
                }
            }
            
            EvidencePreviewGrid()
                .frame(height: 180)
        }
    }
    
    private var startInvestigationButton: some View {
        Button(action: { showingCase = true }) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Start Investigation")
                    .font(.headline)
            }
            .foregroundColor(Color("DarkNavy"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color("AccentGold"))
            .cornerRadius(12)
        }
        .disabled(gameManager.todayCase == nil)
        .opacity(gameManager.todayCase == nil ? 0.5 : 1)
    }
}

struct CaseCardView: View {
    let caseItem: Case
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: caseItem.category.iconName)
                    .foregroundColor(Color(hex: caseItem.category.color))
                
                Text(caseItem.title)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < caseItem.difficulty ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(i < caseItem.difficulty ? Color("AccentGold") : .gray)
                    }
                }
            }
            
            Text(caseItem.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Label(caseItem.category.rawValue, systemImage: caseItem.category.iconName)
                    .font(.caption)
                    .foregroundColor(Color(hex: caseItem.category.color))
                
                Spacer()
                
                if caseItem.isCompleted {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("In Progress", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(16)
        .background(Color("CardDark"))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("AccentRed").opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("CardDark"))
        .cornerRadius(12)
    }
}

struct EvidencePreviewGrid: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<9) { index in
                if index < GameManager().collectedEvidence.count {
                    EvidenceCell(evidence: GameManager().collectedEvidence[index], isLocked: false)
                } else {
                    EvidenceCell(evidence: nil, isLocked: true)
                }
            }
        }
        .padding(12)
        .background(Color("CardDark"))
        .cornerRadius(12)
    }
}

struct EvidenceCell: View {
    let evidence: Evidence?
    let isLocked: Bool
    
    var body: some View {
        ZStack {
            if let evidence = evidence {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: evidence.type.iconName)
                            .foregroundColor(Color("AccentGold"))
                    )
                
                if evidence.isCollected {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(4)
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        Text("?")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(GameManager())
}