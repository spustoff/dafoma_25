//
//  ContentView.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

// MARK: - Navigation Environment
struct NavigateToMainMenuKey: EnvironmentKey {
    static let defaultValue: () -> Void = { }
}

extension EnvironmentValues {
    var navigateToMainMenu: () -> Void {
        get { self[NavigateToMainMenuKey.self] }
        set { self[NavigateToMainMenuKey.self] = newValue }
    }
}

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var dataService = DataService()
    @State private var showOnboarding = false
    @State private var currentView: AppView = .mainMenu
    
    enum AppView {
        case mainMenu
        case game
        case scoreboard
        case settings
        case achievements
        case onboarding
    }
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView()
                    .environmentObject(gameViewModel)
                    .environment(\.navigateToMainMenu) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            print("Navigating from onboarding to main menu")
                            showOnboarding = false
                            currentView = .mainMenu
                        }
                    }
                    .onDisappear {
                        print("OnboardingView disappeared")
                        if !showOnboarding {
                            currentView = .mainMenu
                        }
                    }
            } else {
                switch currentView {
                case .mainMenu:
                    mainMenuView
                case .game:
                    GameView()
                        .environmentObject(gameViewModel)
                        .environment(\.navigateToMainMenu) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .mainMenu
                            }
                        }
                case .scoreboard:
                    ScoreBoardView()
                        .environmentObject(gameViewModel)
                        .environment(\.navigateToMainMenu) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .mainMenu
                            }
                        }
                case .settings:
                    SettingsView()
                        .environmentObject(gameViewModel)
                        .environment(\.navigateToMainMenu) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .mainMenu
                            }
                        }
                case .achievements:
                    AchievementsView()
                        .environmentObject(gameViewModel)
                        .environment(\.navigateToMainMenu) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .mainMenu
                            }
                        }
                case .onboarding:
                    OnboardingView()
                        .environmentObject(gameViewModel)
                        .environment(\.navigateToMainMenu) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .mainMenu
                            }
                        }
                }
            }
        }
        .onAppear {
            print("ContentView appeared")
            checkOnboardingStatus()
            print("showOnboarding: \(showOnboarding)")
            print("currentView: \(currentView)")
        }
    }
    
    // MARK: - Main Menu View
    private var mainMenuView: some View {
        VStack(spacing: 20) {
            // Logo/Title
            VStack(spacing: 16) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "28a809"))
                
                Text("SportPulse Avi")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Immersive Sports Gaming Experience")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Main Menu Buttons
            VStack(spacing: 16) {
                Button {
                    print("Start Game button tapped!")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .game
                    }
                } label: {
                    Text("Start Game")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "28a809"), Color(hex: "d17305")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(MainMenuButtonStyle())
                
                Button {
                    print("Leaderboard button tapped!")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .scoreboard
                    }
                } label: {
                    Text("Leaderboard")
                        .font(.headline)
                        .foregroundColor(Color(hex: "28a809"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "28a809"), lineWidth: 2)
                                .background(Color.clear)
                        )
                }
                .buttonStyle(MainMenuButtonStyle())
                
                Button {
                    print("Settings button tapped!")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .settings
                    }
                } label: {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(Color(hex: "28a809"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "28a809"), lineWidth: 2)
                                .background(Color.clear)
                        )
                }
                .buttonStyle(MainMenuButtonStyle())
                
                Button {
                    print("Achievements button tapped!")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .achievements
                    }
                } label: {
                    Text("Achievements")
                        .font(.headline)
                        .foregroundColor(Color(hex: "d17305"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "d17305"), lineWidth: 2)
                                .background(Color.clear)
                        )
                }
                .buttonStyle(MainMenuButtonStyle())
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Footer
            Text("Ready to compete?")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "0e0e0e"),
                    Color(hex: "1a1a1a"),
                    Color(hex: "0e0e0e")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Helper Methods
    private func checkOnboardingStatus() {
        let onboardingCompleted = dataService.isOnboardingCompleted()
        
        // Force show onboarding if user profile is incomplete
        let hasValidProfile = !gameViewModel.userProfile.username.isEmpty
        
        showOnboarding = !onboardingCompleted || !hasValidProfile
        
        print("Onboarding completed: \(onboardingCompleted)")
        print("Has valid profile: \(hasValidProfile)")
        print("Will show onboarding: \(showOnboarding)")
        
        // Ensure we start with the correct view
        if showOnboarding {
            currentView = .onboarding
        } else {
            currentView = .mainMenu
        }
    }
}



// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - Custom Button Style
struct MainMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
