import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case cases = "Cases"
        case evidence = "Evidence"
        case stats = "Stats"
        case settings = "Settings"
        
        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .cases: return "folder.fill"
            case .evidence: return "magnifyingglass"
            case .stats: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.iconName)
                }
                .tag(Tab.home)
            
            CaseListView()
                .tabItem {
                    Label(Tab.cases.rawValue, systemImage: Tab.cases.iconName)
                }
                .tag(Tab.cases)
            
            EvidenceBoardView()
                .tabItem {
                    Label(Tab.evidence.rawValue, systemImage: Tab.evidence.iconName)
                }
                .tag(Tab.evidence)
            
            StatsView()
                .tabItem {
                    Label(Tab.stats.rawValue, systemImage: Tab.stats.iconName)
                }
                .tag(Tab.stats)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.iconName)
                }
                .tag(Tab.settings)
        }
        .tint(Color("AccentGold"))
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
}