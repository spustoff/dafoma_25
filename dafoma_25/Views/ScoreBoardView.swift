//
//  ScoreBoardView.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct ScoreBoardView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @Environment(\.navigateToMainMenu) private var navigateToMainMenu
    @State private var selectedTab = 0
    
    private let tabs = ["Global", "Personal"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Tab Selector
            tabSelector
            
            // Content
            if selectedTab == 0 {
                globalLeaderboardView
            } else {
                personalStatsView
            }
            
            // Bottom Actions
            bottomActions
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
        .preferredColorScheme(.dark)
        .onAppear {
            gameViewModel.loadLeaderboard()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    navigateToMainMenu()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Color(hex: "28a809"))
                }
                
                Spacer()
                
                Text("Leaderboard")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    // Future: Show player stats
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "28a809"))
                }
            }
            
            // User's Rank Card
            userRankCard
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    private var userRankCard: some View {
        HStack(spacing: 16) {
            // Avatar
            Image(systemName: gameViewModel.userProfile.avatar)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "28a809"), Color(hex: "d17305")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(gameViewModel.userProfile.username.isEmpty ? "You" : gameViewModel.userProfile.username)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Text("Level \(gameViewModel.userProfile.stats.level) • \(gameViewModel.userProfile.stats.gamesPlayed) games")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Score & Rank
            VStack(alignment: .trailing, spacing: 4) {
                Text(gameViewModel.formatScore(gameViewModel.userProfile.stats.highScore))
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "28a809"))
                
                Text("#\(calculateUserRank())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "28a809").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    selectedTab = index
                } label: {
                    Text(tabs[index])
                        .font(.headline)
                        .foregroundColor(selectedTab == index ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .fill(selectedTab == index ? 
                                      Color(hex: "28a809").opacity(0.2) : Color.clear)
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Global Leaderboard
    private var globalLeaderboardView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameViewModel.leaderboard.prefix(100)) { entry in
                    leaderboardRow(entry)
                }
                
                if gameViewModel.leaderboard.isEmpty && !gameViewModel.isLoading {
                    emptyStateView
                }
            }
            .padding(.horizontal, 24)
        }
        .refreshable {
            gameViewModel.loadLeaderboard()
        }
    }
    
    private func leaderboardRow(_ entry: LeaderboardEntry) -> some View {
        HStack(spacing: 16) {
            // Rank
            Text("#\(entry.rank)")
                .font(.headline.bold())
                .foregroundColor(rankColor(entry.rank))
                .frame(width: 40, alignment: .leading)
            
            // Player Info
            HStack(spacing: 12) {
                // Avatar placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(entry.username.prefix(1)).uppercased())
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.username)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(timeAgo(from: entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Score
            Text(gameViewModel.formatScore(entry.score))
                .font(.title3.bold())
                .foregroundColor(Color(hex: "28a809"))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(entry.rank <= 3 ? rankBackgroundColor(entry.rank) : Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(entry.rank <= 3 ? rankColor(entry.rank) : Color.clear, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Personal Stats
    private var personalStatsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats Overview
                statsOverviewCard
                
                // Recent Games Placeholder
                VStack(spacing: 16) {
                    Text("Recent Games")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        Text("No recent games")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("Start playing to see your game history!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var statsOverviewCard: some View {
        VStack(spacing: 16) {
            Text("Your Stats")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                statItem("Total Score", gameViewModel.formatScore(gameViewModel.userProfile.stats.totalScore), "sum")
                statItem("High Score", gameViewModel.formatScore(gameViewModel.userProfile.stats.highScore), "star.fill")
                statItem("Games Played", "\(gameViewModel.userProfile.stats.gamesPlayed)", "gamecontroller.fill")
                statItem("Average Score", gameViewModel.formatScore(Int(gameViewModel.userProfile.stats.averageScore)), "chart.line.uptrend.xyaxis")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private func statItem(_ title: String, _ value: String, _ iconName: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(Color(hex: "28a809"))
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.number")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Scores Yet")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("Be the first to submit a score!")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Play Now") {
                navigateToMainMenu()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(40)
    }
    
    // MARK: - Bottom Actions
    private var bottomActions: some View {
        HStack(spacing: 16) {
            Button {
                gameViewModel.submitScore()
            } label: {
                Label("Submit Score", systemImage: "paperplane.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(gameViewModel.userProfile.stats.highScore == 0)
            
            Button {
                // Future: Share functionality
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
    
    // MARK: - Helper Functions
    private func calculateUserRank() -> Int {
        let userScore = gameViewModel.userProfile.stats.highScore
        let rank = gameViewModel.leaderboard.firstIndex { $0.score < userScore } ?? gameViewModel.leaderboard.count
        return rank + 1
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return Color(hex: "d17305") // Gold
        case 2:
            return Color.gray // Silver
        case 3:
            return Color(hex: "e6053a") // Bronze
        default:
            return .secondary
        }
    }
    
    private func rankBackgroundColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return Color(hex: "d17305").opacity(0.1)
        case 2:
            return Color.gray.opacity(0.1)
        case 3:
            return Color(hex: "e6053a").opacity(0.1)
        default:
            return Color.clear
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}



#Preview {
    ScoreBoardView()
        .environmentObject(GameViewModel())
}