//
//  ConnectivityService.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation
import Network
import Combine

class ConnectivityService: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var connectionType: ConnectionType = .none
    @Published var isServerReachable: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var cancellables = Set<AnyCancellable>()
    
    // Mock server for local development
    private let baseURL = "https://api.sportpulse.com/v1"
    private let session = URLSession.shared
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case none
    }
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Network Monitoring
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
                
                if self?.isConnected == true {
                    self?.checkServerReachability()
                } else {
                    self?.isServerReachable = false
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .none
        }
    }
    
    private func checkServerReachability() {
        Task {
            do {
                let url = URL(string: "\(baseURL)/health")!
                let (_, response) = try await session.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    await MainActor.run {
                        self.isServerReachable = httpResponse.statusCode == 200
                    }
                }
            } catch {
                await MainActor.run {
                    self.isServerReachable = false
                }
            }
        }
    }
    
    // MARK: - Leaderboard API
    func fetchLeaderboard() async throws -> [LeaderboardEntry] {
        guard isConnected else {
            throw ConnectivityError.noConnection
        }
        
        // For now, return mock data since we don't have a real server
        return generateMockLeaderboard()
    }
    
    func submitScore(_ entry: LeaderboardEntry) async throws {
        guard isConnected else {
            throw ConnectivityError.noConnection
        }
        
        // Mock implementation - in real app, this would POST to server
        let url = URL(string: "\(baseURL)/leaderboard")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(entry)
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // For development, we'll just simulate success
        // let (_, response) = try await session.data(for: request)
        // Handle response...
    }
    
    // MARK: - Social Features
    func shareAchievement(_ achievement: Achievement) async throws -> String {
        guard isConnected else {
            throw ConnectivityError.noConnection
        }
        
        // Generate shareable link
        let shareData = ShareData(
            type: .achievement,
            title: achievement.title,
            description: achievement.description,
            points: achievement.points,
            timestamp: Date()
        )
        
        // In real implementation, this would upload to server and return URL
        let shareId = UUID().uuidString
        return "https://sportpulse.com/share/\(shareId)"
    }
    
    func shareScore(_ score: Int, challengeType: ChallengeType?) async throws -> String {
        guard isConnected else {
            throw ConnectivityError.noConnection
        }
        
        let shareData = ShareData(
            type: .score,
            title: "New High Score!",
            description: "I just scored \(score) points in SportPulse Avi!",
            points: score,
            challengeType: challengeType,
            timestamp: Date()
        )
        
        // Mock implementation
        let shareId = UUID().uuidString
        return "https://sportpulse.com/share/\(shareId)"
    }
    
    // MARK: - User Authentication (Future)
    func authenticateUser(_ credentials: UserCredentials) async throws -> AuthToken {
        guard isConnected else {
            throw ConnectivityError.noConnection
        }
        
        // Mock implementation
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        return AuthToken(
            token: UUID().uuidString,
            refreshToken: UUID().uuidString,
            expiresAt: Date().addingTimeInterval(3600)
        )
    }
    
    func refreshAuthToken(_ refreshToken: String) async throws -> AuthToken {
        guard isConnected else {
            throw ConnectivityError.noConnection
        }
        
        // Mock implementation
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return AuthToken(
            token: UUID().uuidString,
            refreshToken: refreshToken,
            expiresAt: Date().addingTimeInterval(3600)
        )
    }
    
    // MARK: - Analytics (Privacy-Compliant)
    func trackGameEvent(_ event: GameEvent) async {
        guard isConnected && isServerReachable else { return }
        
        // Only track anonymous, non-personal gameplay metrics
        let anonymousEvent = AnonymousGameEvent(
            eventType: event.type,
            challengeType: event.challengeType,
            score: event.score,
            duration: event.duration,
            timestamp: event.timestamp,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        )
        
        // Send to analytics endpoint
        do {
            let url = URL(string: "\(baseURL)/analytics")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let data = try JSONEncoder().encode(anonymousEvent)
            request.httpBody = data
            
            // Fire and forget - don't wait for response
            _ = try await session.data(for: request)
        } catch {
            // Silently fail - analytics shouldn't impact gameplay
        }
    }
    
    // MARK: - Mock Data
    private func generateMockLeaderboard() -> [LeaderboardEntry] {
        let mockNames = [
            "SportsMaster", "AviChampion", "PulsePlayer", "GameGuru", "ChallengeKing",
            "SkillSeeker", "ScoreStar", "PlayPro", "GameGenius", "SportSage"
        ]
        
        return mockNames.enumerated().map { index, name in
            LeaderboardEntry(
                username: name,
                score: Int.random(in: 500...5000) - (index * 100),
                rank: index + 1,
                date: Date().addingTimeInterval(-Double.random(in: 0...86400 * 7)),
                challengeType: ChallengeType.allCases.randomElement()
            )
        }.sorted { $0.score > $1.score }
    }
    
    // MARK: - Utility
    func getConnectionStatus() -> String {
        if !isConnected {
            return "No Connection"
        }
        
        let typeString = switch connectionType {
        case .wifi: "WiFi"
        case .cellular: "Cellular"
        case .ethernet: "Ethernet"
        case .none: "None"
        }
        
        let serverStatus = isServerReachable ? "Online" : "Offline"
        return "\(typeString) - Server \(serverStatus)"
    }
    
    func canPerformOnlineActions() -> Bool {
        return isConnected && isServerReachable
    }
}

// MARK: - Data Models
struct ShareData: Codable {
    let type: ShareType
    let title: String
    let description: String
    let points: Int
    let challengeType: ChallengeType?
    let timestamp: Date
    
    init(type: ShareType, title: String, description: String, points: Int, challengeType: ChallengeType? = nil, timestamp: Date) {
        self.type = type
        self.title = title
        self.description = description
        self.points = points
        self.challengeType = challengeType
        self.timestamp = timestamp
    }
}

enum ShareType: String, Codable {
    case achievement = "achievement"
    case score = "score"
    case milestone = "milestone"
}

struct UserCredentials: Codable {
    let username: String
    let password: String
}

struct AuthToken: Codable {
    let token: String
    let refreshToken: String
    let expiresAt: Date
}

struct GameEvent {
    let type: GameEventType
    let challengeType: ChallengeType?
    let score: Int?
    let duration: TimeInterval?
    let timestamp: Date
}

struct AnonymousGameEvent: Codable {
    let eventType: GameEventType
    let challengeType: ChallengeType?
    let score: Int?
    let duration: TimeInterval?
    let timestamp: Date
    let appVersion: String
}

enum GameEventType: String, Codable {
    case gameStarted = "game_started"
    case gameCompleted = "game_completed"
    case challengeStarted = "challenge_started"
    case challengeCompleted = "challenge_completed"
    case achievementUnlocked = "achievement_unlocked"
    case scoreSubmitted = "score_submitted"
}

// MARK: - Error Types
enum ConnectivityError: LocalizedError {
    case noConnection
    case serverUnreachable
    case invalidResponse
    case authenticationFailed
    case rateLimited
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .serverUnreachable:
            return "Cannot reach game servers"
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed:
            return "Authentication failed"
        case .rateLimited:
            return "Too many requests. Please try again later"
        case .serverError(let code):
            return "Server error (\(code))"
        }
    }
}

