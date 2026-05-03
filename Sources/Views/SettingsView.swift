import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("DarkNavy").ignoresSafeArea()
                
                List {
                    Section {
                        Toggle("Sound Effects", isOn: $soundEnabled)
                        Toggle("Haptic Feedback", isOn: $hapticEnabled)
                        Toggle("Daily Reminder", isOn: $notificationsEnabled)
                    } header: {
                        Text("General")
                    }
                    .listRowBackground(Color("CardDark"))
                    
                    Section {
                        Toggle("Dark Theme", isOn: $darkModeEnabled)
                        NavigationLink(destination: Text("Theme Settings")) {
                            Text("Theme Settings")
                        }
                    } header: {
                        Text("Appearance")
                    }
                    .listRowBackground(Color("CardDark"))
                    
                    Section {
                        Button(action: { gameManager.resetProgress() }) {
                            HStack {
                                Text("Reset All Progress")
                                    .foregroundColor(Color("AccentRed"))
                                Spacer()
                                Image(systemName: "trash")
                                    .foregroundColor(Color("AccentRed"))
                            }
                        }
                        
                        Button(action: { gameManager.exportData() }) {
                            HStack {
                                Text("Export Game Data")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Color("AccentGold"))
                            }
                        }
                    } header: {
                        Text("Data")
                    }
                    .listRowBackground(Color("CardDark"))
                    
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.white)
                        
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.white)
                    } header: {
                        Text("About")
                    }
                    .listRowBackground(Color("CardDark"))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameManager())
}