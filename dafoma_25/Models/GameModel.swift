//
//  GameModel.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation
import SwiftUI

// MARK: - Game State
enum GameState {
    case menu
    case onboarding
    case settings
    case achievements
    case playing
    case paused
    case gameOver
    case scoreboard
    case arChallenge
}

// MARK: - Player Statistics
struct PlayerStats: Codable {
    var totalScore: Int = 0
    var highScore: Int = 0
    var gamesPlayed: Int = 0
    var averageScore: Double = 0.0
    var achievements: [Achievement] = []
    var level: Int = 1
    var experience: Int = 0
    var skillLevel: SkillLevel = .beginner
    
    mutating func updateStats(newScore: Int) {
        totalScore += newScore
        gamesPlayed += 1
        if newScore > highScore {
            highScore = newScore
        }
        averageScore = Double(totalScore) / Double(gamesPlayed)
        
        // Level progression
        experience += newScore / 10
        let newLevel = (experience / 100) + 1
        if newLevel > level {
            level = newLevel
        }
    }
}

// MARK: - Skill Levels
enum SkillLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate" 
    case advanced = "Advanced"
    case expert = "Expert"
    
    var description: String {
        switch self {
        case .beginner:
            return "Perfect for newcomers to sports gaming"
        case .intermediate:
            return "For players with some gaming experience"
        case .advanced:
            return "Challenging gameplay for experienced players"
        case .expert:
            return "Maximum difficulty for gaming masters"
        }
    }
    
    var difficultyMultiplier: Double {
        switch self {
        case .beginner: return 1.0
        case .intermediate: return 1.3
        case .advanced: return 1.6
        case .expert: return 2.0
        }
    }
}

// MARK: - Achievements
struct Achievement: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let points: Int
    var isUnlocked: Bool = false
    let unlockCondition: AchievementCondition
}

enum AchievementCondition: Codable {
    case scoreReached(Int)
    case gamesPlayed(Int)
    case perfectGame
    case arChallengeCompleted
    case socialShare
}

// MARK: - Game Challenge Types
enum ChallengeType: String, CaseIterable, Codable {
    case timingChallenge = "Timing Challenge"
    case strategyPuzzle = "Strategy Puzzle"
    case reactionTest = "Reaction Test"
    case memoryGame = "Memory Game"
    case arInteraction = "AR Interaction"
    
    var description: String {
        switch self {
        case .timingChallenge:
            return "Test your precision timing skills"
        case .strategyPuzzle:
            return "Solve complex sports-themed puzzles"
        case .reactionTest:
            return "Quick reflexes determine success"
        case .memoryGame:
            return "Remember patterns and sequences"
        case .arInteraction:
            return "Interactive augmented reality challenges"
        }
    }
    
    var basePoints: Int {
        switch self {
        case .timingChallenge: return 100
        case .strategyPuzzle: return 150
        case .reactionTest: return 80
        case .memoryGame: return 120
        case .arInteraction: return 200
        }
    }
}

// MARK: - Game Challenge
struct GameChallenge: Identifiable, Codable {
    let id = UUID()
    let type: ChallengeType
    let difficulty: Int // 1-10
    let timeLimit: TimeInterval?
    var isCompleted: Bool = false
    var score: Int = 0
    var startTime: Date?
    var endTime: Date?
    
    var completionTime: TimeInterval? {
        guard let start = startTime, let end = endTime else { return nil }
        return end.timeIntervalSince(start)
    }
    
    var finalScore: Int {
        let baseScore = type.basePoints * difficulty
        let timeBonus = timeLimit != nil && completionTime != nil ? 
            max(0, Int((timeLimit! - completionTime!) * 10)) : 0
        return baseScore + timeBonus + score
    }
}

// MARK: - Game Session
class GameSession: ObservableObject {
    @Published var currentState: GameState = .menu
    @Published var currentChallenge: GameChallenge?
    @Published var sessionScore: Int = 0
    @Published var challengesCompleted: [GameChallenge] = []
    @Published var isARAvailable: Bool = false
    @Published var timeRemaining: TimeInterval = 0
    
    private var timer: Timer?
    
    func startChallenge(_ challenge: GameChallenge) {
        var newChallenge = challenge
        newChallenge.startTime = Date()
        currentChallenge = newChallenge
        currentState = .playing
        
        if let timeLimit = challenge.timeLimit {
            timeRemaining = timeLimit
            startTimer()
        }
    }
    
    func completeChallenge(withScore score: Int) {
        guard var challenge = currentChallenge else { return }
        
        challenge.endTime = Date()
        challenge.score = score
        challenge.isCompleted = true
        
        challengesCompleted.append(challenge)
        sessionScore += challenge.finalScore
        
        stopTimer()
        currentChallenge = nil
        currentState = .menu
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeChallenge(withScore: 0)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func pauseGame() {
        currentState = .paused
        timer?.invalidate()
    }
    
    func resumeGame() {
        currentState = .playing
        if currentChallenge?.timeLimit != nil && timeRemaining > 0 {
            startTimer()
        }
    }
    
    func endSession() {
        stopTimer()
        currentState = .gameOver
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    var id = UUID()
    var username: String = ""
    var avatar: String = "person.circle.fill"
    var stats: PlayerStats = PlayerStats()
    var preferences: GamePreferences = GamePreferences()
    var createdAt: Date = Date()
    var lastPlayedAt: Date = Date()
}

// MARK: - Game Preferences
struct GamePreferences: Codable {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hapticFeedbackEnabled: Bool = true
    var notificationsEnabled: Bool = true
    var preferredSkillLevel: SkillLevel = .beginner
    var autoSaveEnabled: Bool = true
    var accessibilityMode: Bool = false
    var colorBlindSupport: Bool = false
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Codable, Identifiable {
    let id = UUID()
    let username: String
    let score: Int
    let rank: Int
    let date: Date
    let challengeType: ChallengeType?
}
