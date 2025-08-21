//
//  DataService.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation
import SwiftUI

class DataService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // MARK: - Keys
    private enum Keys {
        static let userProfile = "UserProfile"
        static let gameHistory = "GameHistory"
        static let achievements = "Achievements"
        static let onboardingCompleted = "OnboardingCompleted"
        static let lastSyncDate = "LastSyncDate"
    }
    
    // MARK: - File URLs
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var gameDataURL: URL {
        documentsDirectory.appendingPathComponent("gamedata.json")
    }
    
    private var backupURL: URL {
        documentsDirectory.appendingPathComponent("gamedata_backup.json")
    }
    
    // MARK: - User Profile
    func loadUserProfile() async throws -> UserProfile? {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    // Try loading from JSON file first (more robust)
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        let data = try Data(contentsOf: self.gameDataURL)
                        let gameData = try JSONDecoder().decode(GameData.self, from: data)
                        continuation.resume(returning: gameData.userProfile)
                        return
                    }
                    
                    // Fallback to UserDefaults
                    if let data = self.userDefaults.data(forKey: Keys.userProfile) {
                        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                        continuation.resume(returning: profile)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    continuation.resume(throwing: DataServiceError.loadFailed(error))
                }
            }
        }
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    // Save to JSON file
                    var gameData = GameData()
                    
                    // Load existing data if available
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        let existingData = try Data(contentsOf: self.gameDataURL)
                        gameData = try JSONDecoder().decode(GameData.self, from: existingData)
                    }
                    
                    gameData.userProfile = profile
                    gameData.lastUpdated = Date()
                    
                    // Create backup
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        try self.fileManager.copyItem(at: self.gameDataURL, to: self.backupURL)
                    }
                    
                    // Save new data
                    let data = try JSONEncoder().encode(gameData)
                    try data.write(to: self.gameDataURL)
                    
                    // Also save to UserDefaults as backup
                    let profileData = try JSONEncoder().encode(profile)
                    self.userDefaults.set(profileData, forKey: Keys.userProfile)
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DataServiceError.saveFailed(error))
                }
            }
        }
    }
    
    // MARK: - Game History
    func saveGameSession(_ session: GameSession) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    var gameData = GameData()
                    
                    // Load existing data
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        let existingData = try Data(contentsOf: self.gameDataURL)
                        gameData = try JSONDecoder().decode(GameData.self, from: existingData)
                    }
                    
                    // Create game history entry
                    let historyEntry = GameHistoryEntry(
                        sessionId: UUID(),
                        date: Date(),
                        totalScore: session.sessionScore,
                        challengesCompleted: session.challengesCompleted,
                        duration: 0 // Calculate based on session
                    )
                    
                    gameData.gameHistory.append(historyEntry)
                    gameData.lastUpdated = Date()
                    
                    // Keep only last 100 sessions
                    if gameData.gameHistory.count > 100 {
                        gameData.gameHistory = Array(gameData.gameHistory.suffix(100))
                    }
                    
                    let data = try JSONEncoder().encode(gameData)
                    try data.write(to: self.gameDataURL)
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DataServiceError.saveFailed(error))
                }
            }
        }
    }
    
    func loadGameHistory() async throws -> [GameHistoryEntry] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        let data = try Data(contentsOf: self.gameDataURL)
                        let gameData = try JSONDecoder().decode(GameData.self, from: data)
                        continuation.resume(returning: gameData.gameHistory)
                    } else {
                        continuation.resume(returning: [])
                    }
                } catch {
                    continuation.resume(throwing: DataServiceError.loadFailed(error))
                }
            }
        }
    }
    
    // MARK: - Settings
    func isOnboardingCompleted() -> Bool {
        return userDefaults.bool(forKey: Keys.onboardingCompleted)
    }
    
    func markOnboardingCompleted() {
        userDefaults.set(true, forKey: Keys.onboardingCompleted)
    }
    
    func resetOnboarding() {
        userDefaults.removeObject(forKey: Keys.onboardingCompleted)
    }
    
    // MARK: - Data Management
    func exportGameData() async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        let data = try Data(contentsOf: self.gameDataURL)
                        continuation.resume(returning: data)
                    } else {
                        // Create empty game data
                        let emptyData = GameData()
                        let data = try JSONEncoder().encode(emptyData)
                        continuation.resume(returning: data)
                    }
                } catch {
                    continuation.resume(throwing: DataServiceError.exportFailed(error))
                }
            }
        }
    }
    
    func importGameData(_ data: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    // Validate data
                    let gameData = try JSONDecoder().decode(GameData.self, from: data)
                    
                    // Create backup of current data
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        try self.fileManager.copyItem(at: self.gameDataURL, to: self.backupURL)
                    }
                    
                    // Save imported data
                    try data.write(to: self.gameDataURL)
                    
                    // Update UserDefaults
                    if let profileData = try? JSONEncoder().encode(gameData.userProfile) {
                        self.userDefaults.set(profileData, forKey: Keys.userProfile)
                    }
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DataServiceError.importFailed(error))
                }
            }
        }
    }
    
    func resetAllData() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    // Remove files
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        try self.fileManager.removeItem(at: self.gameDataURL)
                    }
                    
                    if self.fileManager.fileExists(atPath: self.backupURL.path) {
                        try self.fileManager.removeItem(at: self.backupURL)
                    }
                    
                    // Clear UserDefaults
                    self.userDefaults.removeObject(forKey: Keys.userProfile)
                    self.userDefaults.removeObject(forKey: Keys.gameHistory)
                    self.userDefaults.removeObject(forKey: Keys.achievements)
                    self.userDefaults.removeObject(forKey: Keys.onboardingCompleted)
                    self.userDefaults.removeObject(forKey: Keys.lastSyncDate)
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DataServiceError.resetFailed(error))
                }
            }
        }
    }
    
    // MARK: - Backup & Restore
    func createBackup() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                        // Create timestamped backup
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                        let timestamp = formatter.string(from: Date())
                        
                        let backupFileName = "gamedata_backup_\(timestamp).json"
                        let timestampedBackupURL = self.documentsDirectory.appendingPathComponent(backupFileName)
                        
                        try self.fileManager.copyItem(at: self.gameDataURL, to: timestampedBackupURL)
                        
                        // Also update the main backup
                        if self.fileManager.fileExists(atPath: self.backupURL.path) {
                            try self.fileManager.removeItem(at: self.backupURL)
                        }
                        try self.fileManager.copyItem(at: self.gameDataURL, to: self.backupURL)
                    }
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: DataServiceError.backupFailed(error))
                }
            }
        }
    }
    
    func restoreFromBackup() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    if self.fileManager.fileExists(atPath: self.backupURL.path) {
                        // Validate backup data
                        let backupData = try Data(contentsOf: self.backupURL)
                        _ = try JSONDecoder().decode(GameData.self, from: backupData)
                        
                        // Restore backup
                        if self.fileManager.fileExists(atPath: self.gameDataURL.path) {
                            try self.fileManager.removeItem(at: self.gameDataURL)
                        }
                        
                        try self.fileManager.copyItem(at: self.backupURL, to: self.gameDataURL)
                        
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: DataServiceError.noBackupFound)
                    }
                } catch {
                    continuation.resume(throwing: DataServiceError.restoreFailed(error))
                }
            }
        }
    }
    
    // MARK: - Utility
    func getDataSize() -> String {
        var totalSize: Int64 = 0
        
        if fileManager.fileExists(atPath: gameDataURL.path) {
            if let attributes = try? fileManager.attributesOfItem(atPath: gameDataURL.path) {
                totalSize += attributes[.size] as? Int64 ?? 0
            }
        }
        
        if fileManager.fileExists(atPath: backupURL.path) {
            if let attributes = try? fileManager.attributesOfItem(atPath: backupURL.path) {
                totalSize += attributes[.size] as? Int64 ?? 0
            }
        }
        
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

// MARK: - Data Models
struct GameData: Codable {
    var userProfile: UserProfile = UserProfile()
    var gameHistory: [GameHistoryEntry] = []
    var lastUpdated: Date = Date()
    var version: String = "1.0"
}

struct GameHistoryEntry: Codable, Identifiable {
    var id = UUID()
    let sessionId: UUID
    let date: Date
    let totalScore: Int
    let challengesCompleted: [GameChallenge]
    let duration: TimeInterval
}

// MARK: - Error Types
enum DataServiceError: LocalizedError {
    case loadFailed(Error)
    case saveFailed(Error)
    case exportFailed(Error)
    case importFailed(Error)
    case resetFailed(Error)
    case backupFailed(Error)
    case restoreFailed(Error)
    case noBackupFound
    
    var errorDescription: String? {
        switch self {
        case .loadFailed(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .exportFailed(let error):
            return "Failed to export data: \(error.localizedDescription)"
        case .importFailed(let error):
            return "Failed to import data: \(error.localizedDescription)"
        case .resetFailed(let error):
            return "Failed to reset data: \(error.localizedDescription)"
        case .backupFailed(let error):
            return "Failed to create backup: \(error.localizedDescription)"
        case .restoreFailed(let error):
            return "Failed to restore backup: \(error.localizedDescription)"
        case .noBackupFound:
            return "No backup file found"
        }
    }
}
