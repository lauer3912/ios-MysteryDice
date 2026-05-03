import SwiftUI

struct EvidenceBoardView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedEvidence: Evidence?
    @State private var showEvidenceDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkNavy").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let currentCase = gameManager.activeCase {
                            activeCaseSection(currentCase)
                        }
                        
                        allEvidenceSection
                        
                        lieDetectorSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Evidence Board")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEvidenceDetail) {
                if let evidence = selectedEvidence {
                    EvidenceDetailSheet(evidence: evidence)
                }
            }
        }
    }
    
    private func activeCaseSection(_ caseItem: Case) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Case")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(caseItem.title)
                    .font(.subheadline)
                    .foregroundColor(Color("AccentGold"))
            }
            
            // Evidence board with connections
            EvidenceBoardGraphView(evidence: caseItem.evidence, collectedIds: caseItem.collectedEvidenceIds)
                .frame(height: 250)
                .padding(16)
                .background(Color("CardDark"))
                .cornerRadius(12)
        }
    }
    
    private var allEvidenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Collected Evidence")
                .font(.headline)
                .foregroundColor(.white)
            
            if gameManager.collectedEvidence.isEmpty {
                EmptyEvidenceView()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(gameManager.collectedEvidence) { evidence in
                        EvidenceGridCard(evidence: evidence) {
                            selectedEvidence = evidence
                            showEvidenceDetail = true
                        }
                    }
                }
            }
        }
    }
    
    private var lieDetectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lie Detector")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Suspicion Level")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(gameManager.suspicionLevel))%")
                        .foregroundColor(suspicionColor)
                        .bold()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(suspicionColor)
                            .frame(width: geometry.size.width * gameManager.suspicionLevel / 100, height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("Trustworthy")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Spacer()
                    Text("Highly Suspicious")
                        .font(.caption2)
                        .foregroundColor(Color("AccentRed"))
                }
            }
            .padding(16)
            .background(Color("CardDark"))
            .cornerRadius(12)
        }
    }
    
    private var suspicionColor: Color {
        if gameManager.suspicionLevel < 30 {
            return .green
        } else if gameManager.suspicionLevel < 60 {
            return .yellow
        } else {
            return Color("AccentRed")
        }
    }
}

struct EvidenceBoardGraphView: View {
    let evidence: [Evidence]
    let collectedIds: [UUID]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                ForEach(0..<5) { row in
                    ForEach(0..<5) { col in
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 4, height: 4)
                            .position(
                                x: CGFloat(col) * (geometry.size.width / 4),
                                y: CGFloat(row) * (geometry.size.height / 4)
                            )
                    }
                }
                
                // Evidence nodes
                ForEach(Array(evidence.enumerated()), id: \.element.id) { index, ev in
                    let isCollected = collectedIds.contains(ev.id)
                    let position = nodePosition(index: index, in: geometry.size)
                    
                    EvidenceNodeView(evidence: ev, isCollected: isCollected)
                        .position(position)
                }
                
                // Connection lines
                Path { path in
                    // Draw some example connections
                    let collected = evidence.filter { collectedIds.contains($0.id) }
                    if collected.count >= 2 {
                        path.move(to: nodePosition(index: 0, in: geometry.size))
                        path.addLine(to: nodePosition(index: 1, in: geometry.size))
                        if collected.count >= 3 {
                            path.move(to: nodePosition(index: 1, in: geometry.size))
                            path.addLine(to: nodePosition(index: 2, in: geometry.size))
                        }
                    }
                }
                .stroke(Color("AccentRed").opacity(0.5), lineWidth: 2)
            }
        }
    }
    
    private func nodePosition(index: Int, in size: CGSize) -> CGPoint {
        let positions: [(CGFloat, CGFloat)] = [
            (0.2, 0.3), (0.8, 0.2), (0.5, 0.5), (0.3, 0.8), (0.7, 0.7),
            (0.15, 0.6), (0.85, 0.4), (0.4, 0.25), (0.6, 0.75), (0.25, 0.45)
        ]
        
        let pos = index < positions.count ? positions[index] : (CGFloat.random(in: 0.2...0.8), CGFloat.random(in: 0.2...0.8))
        return CGPoint(x: pos.0 * size.width, y: pos.1 * size.height)
    }
}

struct EvidenceNodeView: View {
    let evidence: Evidence
    let isCollected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isCollected ? Color("AccentGold").opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: isCollected ? evidence.type.iconName : "questionmark")
                    .font(.title2)
                    .foregroundColor(isCollected ? Color("AccentGold") : .gray)
            }
            
            if isCollected {
                Text(evidence.name)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
    }
}

struct EvidenceGridCard: View {
    let evidence: Evidence
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("AccentGold").opacity(0.2))
                        .frame(height: 80)
                    
                    Image(systemName: evidence.type.iconName)
                        .font(.largeTitle)
                        .foregroundColor(Color("AccentGold"))
                }
                
                Text(evidence.name)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(12)
            .background(Color("CardDark"))
            .cornerRadius(12)
        }
    }
}

struct EmptyEvidenceView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Evidence Collected")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Start investigating to collect evidence")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color("CardDark"))
        .cornerRadius(12)
    }
}

struct EvidenceDetailSheet: View {
    let evidence: Evidence
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkNavy").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Evidence image placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                            
                            Image(systemName: evidence.type.iconName)
                                .font(.system(size: 64))
                                .foregroundColor(Color("AccentGold"))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(evidence.name)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Label(evidence.type.rawValue, systemImage: evidence.type.iconName)
                                .font(.subheadline)
                                .foregroundColor(Color("AccentGold"))
                            
                            Text(evidence.description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        
                        if let verifiedInfo = evidence.verifiedInfo.isEmpty ? nil : evidence.verifiedInfo {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Verified Info")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(verifiedInfo)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("CardDark"))
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Evidence Detail")
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

#Preview {
    EvidenceBoardView()
        .environmentObject(GameManager())
}