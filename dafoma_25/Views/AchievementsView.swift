//
//  AchievementsView.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @Environment(\.navigateToMainMenu) private var navigateToMainMenu
    @State private var selectedCategory = AchievementCategory.all
    
    private let categories = AchievementCategory.allCases
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Category Selector
            categorySelector
            
            // Achievements Grid
            achievementsGrid
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
                
                Text("Achievements")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                // Progress indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(unlockedCount)/\(totalAchievements)")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "28a809"))
                    
                    Text("Unlocked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            ProgressView(value: Double(unlockedCount), total: Double(totalAchievements))
                .progressViewStyle(AchievementProgressStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                .font(.title2)
                                .foregroundColor(selectedCategory == category ? .white : .secondary)
                            
                            Text(category.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(selectedCategory == category ? .white : .secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCategory == category ? Color(hex: "28a809") : Color.gray.opacity(0.1))
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Achievements Grid
    private var achievementsGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(filteredAchievements) { achievement in
                    achievementCard(achievement)
                }
                
                // Locked achievements placeholders
                ForEach(lockedAchievementsPlaceholders, id: \.id) { placeholder in
                    lockedAchievementCard(placeholder)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Achievement Card
    private func achievementCard(_ achievement: Achievement) -> some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "28a809"), Color(hex: "d17305")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text(achievement.title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                // Points
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(Color(hex: "d17305"))
                    
                    Text("\(achievement.points) pts")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "d17305"))
                }
            }
        }
        .padding(20)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "28a809"), Color(hex: "d17305")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }
    
    // MARK: - Locked Achievement Card
    private func lockedAchievementCard(_ placeholder: LockedAchievement) -> some View {
        VStack(spacing: 16) {
            // Locked Icon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Text("???")
                    .font(.headline.bold())
                    .foregroundColor(.secondary)
                
                Text("Complete more challenges to unlock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                // Hidden points
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("??? pts")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Computed Properties
    private var filteredAchievements: [Achievement] {
        let achievements = gameViewModel.userProfile.stats.achievements.filter { $0.isUnlocked }
        
        switch selectedCategory {
        case .all:
            return achievements
        case .score:
            return achievements.filter { 
                if case .scoreReached = $0.unlockCondition { return true }
                return false
            }
        case .games:
            return achievements.filter {
                if case .gamesPlayed = $0.unlockCondition { return true }
                return false
            }
        case .special:
            return achievements.filter {
                switch $0.unlockCondition {
                case .perfectGame, .arChallengeCompleted, .socialShare:
                    return true
                default:
                    return false
                }
            }
        }
    }
    
    private var unlockedCount: Int {
        gameViewModel.userProfile.stats.achievements.filter { $0.isUnlocked }.count
    }
    
    private var totalAchievements: Int {
        // In a real app, this would be the total number of possible achievements
        return max(unlockedCount + lockedAchievementsPlaceholders.count, 12)
    }
    
    private var lockedAchievementsPlaceholders: [LockedAchievement] {
        let lockedCount = max(0, 8 - unlockedCount) // Show up to 8 locked placeholders
        return (0..<lockedCount).map { LockedAchievement(id: $0) }
    }
}

// MARK: - Supporting Types
enum AchievementCategory: String, CaseIterable {
    case all = "All"
    case score = "Score"
    case games = "Games"
    case special = "Special"
    
    var iconName: String {
        switch self {
        case .all: return "star.fill"
        case .score: return "target"
        case .games: return "gamecontroller.fill"
        case .special: return "sparkles"
        }
    }
}

struct LockedAchievement {
    let id: Int
}

// MARK: - Custom Progress Style
struct AchievementProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0.0
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 8)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "28a809"), Color(hex: "d17305")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: CGFloat(progress) * UIScreen.main.bounds.width * 0.85, height: 8)
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}



#Preview {
    AchievementsView()
        .environmentObject(GameViewModel())
}
