import SwiftUI

@main
struct MysteryDiceApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .preferredColorScheme(.dark)
        }
    }
}