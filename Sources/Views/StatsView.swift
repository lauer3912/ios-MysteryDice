import SwiftUI

struct StatsView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkNavy").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        rankSection
                        
                        statisticsSection
                        
                        achievementsSection
                        
                        endingsCollectionSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var rankSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("AccentGold"), Color("AccentGold").opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 4) {
                    Image(systemName: gameManager.progress.rank.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(Color("DarkNavy"))
                    
                    Text(gameManager.progress.rank.rawValue)
                        .font(.headline)
                        .foregroundColor(Color("DarkNavy"))
                }
            }
            
            VStack(spacing: 4) {
                Text("Reputation Points")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("\(gameManager.progress.reputationPoints)")
                    .font(.title.bold())
                    .foregroundColor(Color("AccentGold"))
                
                if let nextRank = nextRank {
                    Text("Next: \(nextRank.rawValue) (\(nextRank.requiredPoints) pts)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("AccentGold"))
                        .frame(width: geometry.size.width * rankProgress, height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 40)
        }
        .padding(24)
        .background(Color("CardDark"))
        .cornerRadius(16)
    }
    
    private var nextRank: DetectiveRank? {
        let ranks = DetectiveRank.allCases
        if let currentIndex = ranks.firstIndex(of: gameManager.progress.rank),
           currentIndex + 1 < ranks.count {
            return ranks[currentIndex + 1]
        }
        return nil
    }
    
    private var rankProgress: CGFloat {
        let ranks = DetectiveRank.allCases
        guard let currentIndex = ranks.firstIndex(of: gameManager.progress.rank) else { return 0 }
        
        let currentRequired = ranks[currentIndex].requiredPoints
        let nextRequired = currentIndex + 1 < ranks.count ? ranks[currentIndex + 1].requiredPoints : currentRequired + 1000
        
        let progress = (gameManager.progress.reputationPoints - currentRequired) * 100 / (nextRequired - currentRequired)
        return CGFloat(min(max(progress, 0), 100)) / 100
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatBox(title: "Cases Solved", value: "\(gameManager.progress.totalCasesCompleted)", icon: "checkmark.seal.fill", color: .green)
                StatBox(title: "Total Play Time", value: formatTime(gameManager.progress.statistics.totalPlayTime), icon: "clock.fill", color: .blue)
                StatBox(title: "Avg Solve Time", value: formatTime(gameManager.progress.statistics.averageSolveTime), icon: "timer", color: .orange)
                StatBox(title: "Best Time", value: formatTime(gameManager.progress.statistics.bestTime), icon: "trophy.fill", color: Color("AccentGold"))
                StatBox(title: "Correct Endings", value: "\(gameManager.progress.statistics.totalCorrectEndings)", icon: "star.fill", color: .green)
                StatBox(title: "Wrong Endings", value: "\(gameManager.progress.statistics.totalWrongEndings)", icon: "xmark.circle.fill", color: Color("AccentRed"))
                StatBox(title: "Evidence Collected", value: "\(gameManager.progress.statistics.evidenceCollected)", icon: "doc.fill", color: Color("AccentGold"))
                StatBox(title: "Suspects Interrogated", value: "\(gameManager.progress.statistics.suspectsInterrogated)", icon: "person.fill.questionmark", color: .purple)
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(gameManager.progress.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
    
    private var endingsCollectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Endings Collection")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                let totalEndings = gameManager.allCases.reduce(0) { $0 + $1.endings.count }
                let collectedEndings = gameManager.progress.casesByEnding.values.count
                
                HStack {
                    Text("Endings Discovered")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(collectedEndings)/\(totalEndings)")
                        .foregroundColor(Color("AccentGold"))
                        .bold()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("AccentGold"))
                            .frame(width: geometry.size.width * (collectedEndings * 100 / max(totalEndings, 1)) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(16)
            .background(Color("CardDark"))
            .cornerRadius(12)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct StatBox: View {
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
                .font(.title3.bold())
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("CardDark"))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color("AccentGold").opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? Color("AccentGold") : .gray)
            }
            
            Text(achievement.name)
                .font(.caption)
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80)
        .padding(12)
        .background(Color("CardDark"))
        .cornerRadius(12)
        .opacity(achievement.isUnlocked ? 1 : 0.5)
    }
}

#Preview {
    StatsView()
        .environmentObject(GameManager())
}