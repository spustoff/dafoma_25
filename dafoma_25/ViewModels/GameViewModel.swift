//
//  GameViewModel.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameSession = GameSession()
    @Published var userProfile = UserProfile()
    @Published var availableChallenges: [GameChallenge] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAlert = false
    
    private var dataService = DataService()
    private var connectivityService = ConnectivityService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUserProfile()
        generateChallenges()
        checkARAvailability()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        gameSession.$currentState
            .sink { [weak self] state in
                if state == .gameOver {
                    self?.handleGameOver()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Profile Management
    func loadUserProfile() {
        isLoading = true
        
        Task { @MainActor in
            do {
                if let profile = try await dataService.loadUserProfile() {
                    self.userProfile = profile
                } else {
                    // First time user
                    self.userProfile = UserProfile()
                }
                self.isLoading = false
            } catch {
                self.handleError(error)
            }
        }
    }
    
    func saveUserProfile() {
        Task {
            do {
                try await dataService.saveUserProfile(userProfile)
            } catch {
                await MainActor.run {
                    self.handleError(error)
                }
            }
        }
    }
    
    func saveUserProfileAsync() async throws {
        try await dataService.saveUserProfile(userProfile)
    }
    
    func updateUsername(_ username: String) {
        userProfile.username = username
        saveUserProfile()
    }
    
    func updateSkillLevel(_ skillLevel: SkillLevel) {
        userProfile.preferences.preferredSkillLevel = skillLevel
        saveUserProfile()
        generateChallenges() // Regenerate with new difficulty
    }
    
    // MARK: - Challenge Management
    private func generateChallenges() {
        let skillMultiplier = userProfile.preferences.preferredSkillLevel.difficultyMultiplier
        availableChallenges = []
        
        for challengeType in ChallengeType.allCases {
            let baseDifficulty = Int(5 * skillMultiplier)
            let timeLimit: TimeInterval = TimeInterval(120 / skillMultiplier) // Shorter time for higher skill
            
            let challenge = GameChallenge(
                type: challengeType,
                difficulty: baseDifficulty,
                timeLimit: timeLimit
            )
            
            availableChallenges.append(challenge)
        }
    }
    
    func startChallenge(_ challenge: GameChallenge) {
        gameSession.startChallenge(challenge)
        userProfile.lastPlayedAt = Date()
    }
    
    func completeCurrentChallenge(withScore score: Int) {
        gameSession.completeChallenge(withScore: score)
        
        // Update user stats
        userProfile.stats.updateStats(newScore: gameSession.sessionScore)
        
        // Check for achievements
        checkAchievements()
        
        saveUserProfile()
    }
    
    func pauseGame() {
        gameSession.pauseGame()
    }
    
    func resumeGame() {
        gameSession.resumeGame()
    }
    
    func endCurrentSession() {
        gameSession.endSession()
    }
    
    // MARK: - AR Integration (Removed)
    private func checkARAvailability() {
        // AR functionality has been removed for stability
        gameSession.isARAvailable = false
    }
    
    func startARChallenge() {
        // AR functionality has been removed for stability
        showError("AR feature is currently unavailable")
    }
    
    // MARK: - Achievements
    private func checkAchievements() {
        var newAchievements: [Achievement] = []
        
        // Score-based achievements
        if userProfile.stats.highScore >= 1000 && !hasAchievement("Score Master") {
            newAchievements.append(Achievement(
                title: "Score Master",
                description: "Reach a high score of 1000 points",
                iconName: "star.fill",
                points: 100,
                isUnlocked: true,
                unlockCondition: .scoreReached(1000)
            ))
        }
        
        // Games played achievements
        if userProfile.stats.gamesPlayed >= 10 && !hasAchievement("Dedicated Player") {
            newAchievements.append(Achievement(
                title: "Dedicated Player", 
                description: "Play 10 games",
                iconName: "gamecontroller.fill",
                points: 50,
                isUnlocked: true,
                unlockCondition: .gamesPlayed(10)
            ))
        }
        
        // Memory Master achievement
        if gameSession.challengesCompleted.contains(where: { $0.type == .memoryGame }) && 
           !hasAchievement("Memory Master") {
            newAchievements.append(Achievement(
                title: "Memory Master",
                description: "Complete your first memory challenge",
                iconName: "brain.head.profile",
                points: 150,
                isUnlocked: true,
                unlockCondition: .challengeCompleted
            ))
        }
        
        userProfile.stats.achievements.append(contentsOf: newAchievements)
        
        if !newAchievements.isEmpty {
            // Show achievement notification
            showAchievementUnlocked(newAchievements)
        }
    }
    
    private func hasAchievement(_ title: String) -> Bool {
        return userProfile.stats.achievements.contains { $0.title == title }
    }
    
    private func showAchievementUnlocked(_ achievements: [Achievement]) {
        // This would trigger a UI notification
        // For now, we'll just set an alert
        let titles = achievements.map { $0.title }.joined(separator: ", ")
        showError("New Achievement(s) Unlocked: \(titles)")
    }
    
    // MARK: - Leaderboard
    func loadLeaderboard() {
        isLoading = true
        
        Task { @MainActor in
            do {
                self.leaderboard = try await connectivityService.fetchLeaderboard()
                self.isLoading = false
            } catch {
                self.handleError(error)
            }
        }
    }
    
    func submitScore() {
        guard userProfile.stats.highScore > 0 else { return }
        
        let entry = LeaderboardEntry(
            username: userProfile.username.isEmpty ? "Anonymous" : userProfile.username,
            score: userProfile.stats.highScore,
            rank: 0, // Will be calculated server-side
            date: Date(),
            challengeType: nil
        )
        
        Task {
            do {
                try await connectivityService.submitScore(entry)
                await MainActor.run {
                    self.loadLeaderboard()
                }
            } catch {
                await MainActor.run {
                    self.handleError(error)
                }
            }
        }
    }
    
    // MARK: - Game Over Handling
    private func handleGameOver() {
        // Final score calculation
        let finalScore = gameSession.sessionScore
        
        // Update stats
        userProfile.stats.updateStats(newScore: finalScore)
        
        // Check achievements
        checkAchievements()
        
        // Save profile
        saveUserProfile()
        
        // Auto-submit to leaderboard if high score
        if finalScore > 0 && finalScore >= userProfile.stats.highScore {
            submitScore()
        }
    }
    
    // MARK: - Social Features
    func shareScore() {
        // This would integrate with iOS share sheet
        let _ = "I just scored \(userProfile.stats.highScore) points in SportPulse Avi! Can you beat my score?"
        // Implementation would use UIActivityViewController
    }
    
    // MARK: - Settings
    func updateGamePreferences(_ preferences: GamePreferences) {
        userProfile.preferences = preferences
        saveUserProfile()
    }
    
    func resetGameData() {
        userProfile = UserProfile()
        gameSession = GameSession()
        saveUserProfile()
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showingAlert = true
        isLoading = false
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingAlert = true
    }
    
    // MARK: - Utility
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formatScore(_ score: Int) -> String {
        if score >= 1000000 {
            return String(format: "%.1fM", Double(score) / 1000000)
        } else if score >= 1000 {
            return String(format: "%.1fK", Double(score) / 1000)
        }
        return "\(score)"
    }
}
