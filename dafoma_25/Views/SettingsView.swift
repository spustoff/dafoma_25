//
//  SettingsView.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @Environment(\.navigateToMainMenu) private var navigateToMainMenu
    @State private var showingResetAlert = false
    @State private var showingDataExport = false
    @State private var showingDataImport = false
    @State private var username = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    profileSection
                    
                    // Game Preferences
                    gamePreferencesSection
                    
                    // Audio Settings
                    audioSection
                    
                    // Accessibility
                    accessibilitySection
                    
                    // Data Management
                    dataManagementSection
                    
                    // About
                    aboutSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        navigateToMainMenu()
                    }
                    .foregroundColor(Color(hex: "28a809"))
                }
            }
        }
        .onAppear {
            username = gameViewModel.userProfile.username
        }
        .alert("Reset Game Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameViewModel.resetGameData()
            }
        } message: {
            Text("This will permanently delete all your game data, including scores, achievements, and progress. This action cannot be undone.")
        }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Profile", icon: "person.circle.fill")
            
            VStack(spacing: 16) {
                // Avatar Selection
                HStack {
                    Text("Avatar")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        ForEach(["person.circle.fill", "gamecontroller.fill", "star.circle.fill", "crown.fill"], id: \.self) { icon in
                            Button {
                                gameViewModel.userProfile.avatar = icon
                                gameViewModel.saveUserProfile()
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(gameViewModel.userProfile.avatar == icon ? Color(hex: "28a809") : .secondary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(gameViewModel.userProfile.avatar == icon ? Color(hex: "28a809").opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                }
                
                // Username
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .foregroundColor(.white)
                    
                    TextField("Enter username", text: $username)
                        .textFieldStyle(CustomTextFieldStyle())
                        .onSubmit {
                            gameViewModel.updateUsername(username)
                        }
                }
                
                // Stats Summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level \(gameViewModel.userProfile.stats.level)")
                            .font(.headline)
                            .foregroundColor(Color(hex: "28a809"))
                        
                        Text("\(gameViewModel.userProfile.stats.gamesPlayed) games played")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Best: \(gameViewModel.formatScore(gameViewModel.userProfile.stats.highScore))")
                            .font(.headline)
                            .foregroundColor(Color(hex: "d17305"))
                        
                        Text("\(gameViewModel.userProfile.stats.achievements.count) achievements")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // MARK: - Game Preferences
    private var gamePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Game Preferences", icon: "gamecontroller.fill")
            
            VStack(spacing: 16) {
                // Skill Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty Level")
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        ForEach(SkillLevel.allCases, id: \.self) { level in
                            Button {
                                gameViewModel.updateSkillLevel(level)
                            } label: {
                                Text(level.rawValue)
                                    .font(.caption.bold())
                                    .foregroundColor(gameViewModel.userProfile.preferences.preferredSkillLevel == level ? .white : .secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(gameViewModel.userProfile.preferences.preferredSkillLevel == level ? 
                                                  Color(hex: "28a809") : Color.gray.opacity(0.2))
                                    )
                            }
                        }
                    }
                }
                
                // Auto Save
                Toggle("Auto Save Progress", isOn: Binding(
                    get: { gameViewModel.userProfile.preferences.autoSaveEnabled },
                    set: { newValue in
                        gameViewModel.userProfile.preferences.autoSaveEnabled = newValue
                        gameViewModel.saveUserProfile()
                    }
                ))
                .toggleStyle(CustomToggleStyle())
                
                // Notifications
                Toggle("Game Notifications", isOn: Binding(
                    get: { gameViewModel.userProfile.preferences.notificationsEnabled },
                    set: { newValue in
                        gameViewModel.userProfile.preferences.notificationsEnabled = newValue
                        gameViewModel.saveUserProfile()
                    }
                ))
                .toggleStyle(CustomToggleStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // MARK: - Audio Section
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Audio", icon: "speaker.wave.2.fill")
            
            VStack(spacing: 16) {
                Toggle("Sound Effects", isOn: Binding(
                    get: { gameViewModel.userProfile.preferences.soundEnabled },
                    set: { newValue in
                        gameViewModel.userProfile.preferences.soundEnabled = newValue
                        gameViewModel.saveUserProfile()
                    }
                ))
                .toggleStyle(CustomToggleStyle())
                
                Toggle("Background Music", isOn: Binding(
                    get: { gameViewModel.userProfile.preferences.musicEnabled },
                    set: { newValue in
                        gameViewModel.userProfile.preferences.musicEnabled = newValue
                        gameViewModel.saveUserProfile()
                    }
                ))
                .toggleStyle(CustomToggleStyle())
                
                Toggle("Haptic Feedback", isOn: Binding(
                    get: { gameViewModel.userProfile.preferences.hapticFeedbackEnabled },
                    set: { newValue in
                        gameViewModel.userProfile.preferences.hapticFeedbackEnabled = newValue
                        gameViewModel.saveUserProfile()
                    }
                ))
                .toggleStyle(CustomToggleStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // MARK: - Accessibility Section
    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Accessibility", icon: "accessibility")
            
            VStack(spacing: 16) {
                Toggle("Accessibility Mode", isOn: Binding(
                    get: { gameViewModel.userProfile.preferences.accessibilityMode },
                    set: { newValue in
                        gameViewModel.userProfile.preferences.accessibilityMode = newValue
                        gameViewModel.saveUserProfile()
                    }
                ))
                .toggleStyle(CustomToggleStyle())
                
                Toggle("Color Blind Support", isOn: Binding(
                    get: { gameViewModel.userProfile.preferences.colorBlindSupport },
                    set: { newValue in
                        gameViewModel.userProfile.preferences.colorBlindSupport = newValue
                        gameViewModel.saveUserProfile()
                    }
                ))
                .toggleStyle(CustomToggleStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // MARK: - Data Management
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Data Management", icon: "externaldrive.fill")
            
            VStack(spacing: 12) {
                Button("Export Game Data") {
                    showingDataExport = true
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Import Game Data") {
                    showingDataImport = true
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Reset All Data") {
                    showingResetAlert = true
                }
                .buttonStyle(DestructiveButtonStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("About", icon: "info.circle.fill")
            
            VStack(spacing: 12) {
                Button {
                    // Note: This will need to be handled differently since we can't navigate from settings to achievements directly
                    // For now, let's go back to main menu where user can access other features
                    navigateToMainMenu()
                } label: {
                    HStack {
                        Text("Back to Main Menu")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Version")
                        .foregroundColor(.white)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                        .foregroundColor(.white)
                    Spacer()
                    Text("2025.01.20")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Data Size")
                        .foregroundColor(.white)
                    Spacer()
                    Text("< 1 MB")
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "28a809"))
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
}

// MARK: - Custom Styles
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "28a809").opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                configuration.isOn.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color(hex: "28a809") : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 30)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 26, height: 26)
                            .offset(x: configuration.isOn ? 10 : -10)
                            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    )
            }
        }
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "e6053a"))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameViewModel())
}
