import SwiftUI

struct CaseListView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: CaseCategory? = nil
    @State private var searchText = ""
    
    var filteredCases: [Case] {
        var cases = gameManager.allCases
        
        if let category = selectedCategory {
            cases = cases.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            cases = cases.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return cases
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkNavy").ignoresSafeArea()
                
                VStack(spacing: 16) {
                    categoryFilter
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredCases) { caseItem in
                                NavigationLink(destination: CaseView(caseItem: caseItem)) {
                                    CaseListRowView(caseItem: caseItem)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("Cases")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search cases")
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(CaseCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? Color("DarkNavy") : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("AccentGold") : Color("CardDark"))
                .cornerRadius(20)
        }
    }
}

struct CaseListRowView: View {
    let caseItem: Case
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: caseItem.category.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: caseItem.category.iconName)
                    .font(.title2)
                    .foregroundColor(Color(hex: caseItem.category.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(caseItem.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(caseItem.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < caseItem.difficulty ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(i < caseItem.difficulty ? Color("AccentGold") : .gray)
                        }
                    }
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    if caseItem.isCompleted {
                        Label("Solved", systemImage: "checkmark")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else if caseItem.unlockedAt != nil {
                        Label("In Progress", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Label("Locked", systemImage: "lock")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color("CardDark"))
        .cornerRadius(12)
    }
}

#Preview {
    CaseListView()
        .environmentObject(GameManager())
}