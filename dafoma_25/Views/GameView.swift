//
//  GameView.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @Environment(\.navigateToMainMenu) private var navigateToMainMenu
    @State private var showingPauseMenu = false
    @State private var selectedChallenge: GameChallenge?
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Main Content
            VStack(spacing: 0) {
                // Header
                gameHeader
                
                // Game Content
                switch gameViewModel.gameSession.currentState {
                case .menu:
                    mainMenuView
                case .playing:
                    gameplayView
                case .paused:
                    pausedView
                case .gameOver:
                    gameOverView
                case .scoreboard:
                    ScoreBoardView()
                        .environmentObject(gameViewModel)
                case .arChallenge:
                    ARGameView()
                        .environmentObject(gameViewModel)
                default:
                    mainMenuView
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Game Alert", isPresented: $gameViewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(gameViewModel.errorMessage ?? "")
        }
        .onAppear {
            gameViewModel.loadUserProfile()
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0e0e0e"),
                Color(hex: "1a1a1a"),
                Color(hex: "0e0e0e")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var gameHeader: some View {
        HStack {
            // User Info
            HStack(spacing: 12) {
                Image(systemName: gameViewModel.userProfile.avatar)
                    .font(.title2)
                    .foregroundColor(Color(hex: "28a809"))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .foregroundColor(Color.gray.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(gameViewModel.userProfile.username.isEmpty ? "Player" : gameViewModel.userProfile.username)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Level \(gameViewModel.userProfile.stats.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Score & Level
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(gameViewModel.formatScore(gameViewModel.gameSession.sessionScore))
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "28a809"))
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Best")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(gameViewModel.formatScore(gameViewModel.userProfile.stats.highScore))
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "d17305"))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .blur(radius: 20)
        )
    }
    
    // MARK: - Main Menu
    private var mainMenuView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App Title
            VStack(spacing: 8) {
                Text("SportPulse")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Avi")
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundColor(Color(hex: "28a809"))
            }
            
            // Challenge Grid
            ScrollView(.vertical, showsIndicators: false) {
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(gameViewModel.availableChallenges) { challenge in
                        challengeCard(challenge)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Bottom Actions
            HStack(spacing: 16) {
                Button {
                    // For now, go back to main menu where user can access leaderboard
                    navigateToMainMenu()
                } label: {
                    Label("Leaderboard", systemImage: "list.number")
                }
                .buttonStyle(SecondaryButtonStyle())
                
                if gameViewModel.gameSession.isARAvailable {
                    Button {
                        gameViewModel.startARChallenge()
                    } label: {
                        Label("AR Challenge", systemImage: "arkit")
                    }
                    .buttonStyle(ARButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    private func challengeCard(_ challenge: GameChallenge) -> some View {
        Button {
            selectedChallenge = challenge
            gameViewModel.startChallenge(challenge)
        } label: {
            VStack(spacing: 16) {
                // Challenge Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "28a809").opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: challengeIconName(for: challenge.type))
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Color(hex: "28a809"))
                }
                
                VStack(spacing: 4) {
                    Text(challenge.type.rawValue)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(challenge.type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Difficulty & Points
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { level in
                                Image(systemName: level <= challenge.difficulty ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "d17305"))
                            }
                        }
                        
                        Text("\(challenge.type.basePoints)pts")
                            .font(.caption.bold())
                            .foregroundColor(Color(hex: "28a809"))
                    }
                }
            }
            .padding(20)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "28a809").opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3), value: selectedChallenge?.id == challenge.id)
    }
    
    private func challengeIconName(for type: ChallengeType) -> String {
        switch type {
        case .timingChallenge:
            return "timer"
        case .strategyPuzzle:
            return "puzzlepiece.fill"
        case .reactionTest:
            return "bolt.fill"
        case .memoryGame:
            return "brain.head.profile"
        case .arInteraction:
            return "arkit"
        }
    }
    
    // MARK: - Gameplay View
    private var gameplayView: some View {
        VStack(spacing: 0) {
            // Game HUD
            gameHUD
            
            Spacer()
            
            // Challenge Content
            if let challenge = gameViewModel.gameSession.currentChallenge {
                challengeContentView(challenge)
            }
            
            Spacer()
            
            // Game Controls
            gameControls
        }
        .padding(24)
    }
    
    private var gameHUD: some View {
        HStack {
            // Challenge Info
            VStack(alignment: .leading, spacing: 4) {
                Text(gameViewModel.gameSession.currentChallenge?.type.rawValue ?? "")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Text("Difficulty: \(gameViewModel.gameSession.currentChallenge?.difficulty ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Timer
            if gameViewModel.gameSession.timeRemaining > 0 {
                VStack(spacing: 4) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(gameViewModel.formatTime(gameViewModel.gameSession.timeRemaining))
                        .font(.title2.bold())
                        .foregroundColor(gameViewModel.gameSession.timeRemaining < 30 ? 
                                       Color(hex: "e6053a") : Color(hex: "28a809"))
                }
            }
            
            // Pause Button
            Button {
                showingPauseMenu = true
                gameViewModel.pauseGame()
            } label: {
                Image(systemName: "pause.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .foregroundColor(Color.gray.opacity(0.3))
                    )
            }
        }
    }
    
    @ViewBuilder
    private func challengeContentView(_ challenge: GameChallenge) -> some View {
        switch challenge.type {
        case .timingChallenge:
            TimingChallengeView(challenge: challenge)
                .environmentObject(gameViewModel)
        case .strategyPuzzle:
            StrategyPuzzleView(challenge: challenge)
                .environmentObject(gameViewModel)
        case .reactionTest:
            ReactionTestView(challenge: challenge)
                .environmentObject(gameViewModel)
        case .memoryGame:
            MemoryGameView(challenge: challenge)
                .environmentObject(gameViewModel)
        case .arInteraction:
            ARGameView()
                .environmentObject(gameViewModel)
        }
    }
    
    private var gameControls: some View {
        HStack(spacing: 16) {
            Button("End Game") {
                gameViewModel.endCurrentSession()
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Spacer()
            
            Button("Complete") {
                // This would be called by the individual challenge views
                gameViewModel.completeCurrentChallenge(withScore: 100)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    // MARK: - Paused View
    private var pausedView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "d17305"))
                
                Text("Game Paused")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Take your time and resume when ready")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Resume Game") {
                    gameViewModel.resumeGame()
                    showingPauseMenu = false
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("End Game") {
                    gameViewModel.endCurrentSession()
                    showingPauseMenu = false
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 24)
        }
        .padding(24)
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Results
            VStack(spacing: 16) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "28a809"))
                
                Text("Game Complete!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    Text("Final Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(gameViewModel.formatScore(gameViewModel.gameSession.sessionScore))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "28a809"))
                }
                
                // Performance Stats
                if !gameViewModel.gameSession.challengesCompleted.isEmpty {
                    VStack(spacing: 8) {
                        Text("Challenges Completed: \(gameViewModel.gameSession.challengesCompleted.count)")
                        Text("Average Score: \(Int(gameViewModel.userProfile.stats.averageScore))")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 16) {
                Button("Play Again") {
                    gameViewModel.gameSession = GameSession()
                    navigateToMainMenu()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                HStack(spacing: 16) {
                    Button("View Leaderboard") {
                        // For now, just go back to main menu where user can access leaderboard
                        navigateToMainMenu()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Share Score") {
                        gameViewModel.shareScore()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(24)
    }
}

// MARK: - Challenge Views (Placeholder implementations)
struct TimingChallengeView: View {
    let challenge: GameChallenge
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var progress: Double = 0.0
    @State private var isActive = false
    @State private var round = 1
    @State private var totalScore = 0
    @State private var showFeedback = false
    @State private var lastScore = 0
    
    private let maxRounds = 5
    
    var body: some View {
        VStack(spacing: 32) {
            // Instructions
            VStack(spacing: 8) {
                Text("Perfect Timing Challenge")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Tap when the circle is complete!")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Round \(round)/\(maxRounds)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "28a809"))
            }
            
            // Score Display
            HStack {
                VStack {
                    Text("Total Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalScore)")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "28a809"))
                }
                
                Spacer()
                
                if showFeedback {
                    VStack {
                        Text("Last Round")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("+\(lastScore)")
                            .font(.title3.bold())
                            .foregroundColor(feedbackColor)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 40)
            
            // Timing Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(Color(hex: "28a809"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: Double.random(in: 2.0...4.0)), value: progress)
                
                Button(action: handleTap) {
                    Text("TAP!")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                .frame(width: 120, height: 120)
                .background(Circle().fill(Color(hex: "28a809")))
                .scaleEffect(isActive ? 1.0 : 0.9)
                .animation(.spring(response: 0.3), value: isActive)
            }
            
            // Accuracy Guide
            HStack(spacing: 20) {
                accuracyIndicator("Perfect", Color(hex: "28a809"), "95-100%")
                accuracyIndicator("Good", Color(hex: "d17305"), "80-94%")
                accuracyIndicator("Okay", Color.yellow, "60-79%")
            }
        }
        .onAppear {
            startNewRound()
        }
    }
    
    private func accuracyIndicator(_ title: String, _ color: Color, _ range: String) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(title)
                .font(.caption.bold())
                .foregroundColor(color)
            Text(range)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var feedbackColor: Color {
        if lastScore >= 950 { return Color(hex: "28a809") }
        else if lastScore >= 800 { return Color(hex: "d17305") }
        else { return .yellow }
    }
    
    private func startNewRound() {
        isActive = true
        progress = 0.0
        showFeedback = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                progress = 1.0
            }
        }
    }
    
    private func handleTap() {
        let accuracy = 1.0 - abs(progress - 1.0)
        lastScore = Int(accuracy * 1000)
        totalScore += lastScore
        
        withAnimation(.spring(response: 0.5)) {
            showFeedback = true
        }
        
        if round >= maxRounds {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                gameViewModel.completeCurrentChallenge(withScore: totalScore)
            }
        } else {
            round += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                startNewRound()
            }
        }
    }
}

struct StrategyPuzzleView: View {
    let challenge: GameChallenge
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Strategy Puzzle")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("Solve the sports-themed puzzle!")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Placeholder puzzle grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(0..<9) { index in
                    Rectangle()
                        .fill(Color(hex: "28a809").opacity(0.3))
                        .frame(height: 60)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

struct ReactionTestView: View {
    let challenge: GameChallenge
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var showTarget = false
    @State private var targetPosition = CGPoint.zero
    @State private var round = 1
    @State private var totalScore = 0
    @State private var reactionTimes: [TimeInterval] = []
    @State private var targetAppearTime: Date?
    @State private var isWaiting = true
    @State private var showResults = false
    
    private let maxRounds = 5
    private let gameArea = CGSize(width: 280, height: 280)
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Reaction Speed Test")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Tap the red targets as fast as you can!")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Round \(round)/\(maxRounds)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "28a809"))
            }
            
            // Stats
            HStack(spacing: 30) {
                statDisplay("Score", "\(totalScore)", Color(hex: "28a809"))
                statDisplay("Avg Time", averageTimeText, Color(hex: "d17305"))
                statDisplay("Best", bestTimeText, Color(hex: "e6053a"))
            }
            
            // Game Area
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: gameArea.width, height: gameArea.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                
                if isWaiting && !showTarget {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("Get Ready...")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                } else if showTarget {
                    Circle()
                        .fill(Color(hex: "e6053a"))
                        .frame(width: 60, height: 60)
                        .position(targetPosition)
                        .scaleEffect(showTarget ? 1.0 : 0.0)
                        .animation(.spring(response: 0.2), value: showTarget)
                        .onTapGesture {
                            handleTargetTap()
                        }
                }
                
                if showResults {
                    resultsView
                }
            }
            .frame(width: gameArea.width, height: gameArea.height)
            .clipped()
            
            // Instructions
            if !showResults {
                Text(isWaiting ? "Wait for the red circle..." : "TAP IT NOW!")
                    .font(.headline)
                    .foregroundColor(isWaiting ? .secondary : Color(hex: "e6053a"))
                    .animation(.easeInOut, value: isWaiting)
            }
        }
        .onAppear {
            startNewRound()
        }
    }
    
    private func statDisplay(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(color)
        }
    }
    
    private var averageTimeText: String {
        guard !reactionTimes.isEmpty else { return "--" }
        let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        return String(format: "%.3fs", avg)
    }
    
    private var bestTimeText: String {
        guard let best = reactionTimes.min() else { return "--" }
        return String(format: "%.3fs", best)
    }
    
    private var resultsView: some View {
        VStack(spacing: 16) {
            Text("Challenge Complete!")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                Text("Final Score: \(totalScore)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "28a809"))
                
                Text("Average: \(averageTimeText)")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Best: \(bestTimeText)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button("Continue") {
                gameViewModel.completeCurrentChallenge(withScore: totalScore)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
        )
    }
    
    private func startNewRound() {
        isWaiting = true
        showTarget = false
        showResults = false
        
        let delay = Double.random(in: 1.5...4.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            showTargetAtRandomPosition()
        }
    }
    
    private func showTargetAtRandomPosition() {
        targetPosition = CGPoint(
            x: Double.random(in: 30...(gameArea.width - 30)),
            y: Double.random(in: 30...(gameArea.height - 30))
        )
        
        targetAppearTime = Date()
        isWaiting = false
        
        withAnimation(.spring(response: 0.2)) {
            showTarget = true
        }
        
        // Auto-hide target after 2 seconds if not tapped
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if showTarget {
                handleMissedTarget()
            }
        }
    }
    
    private func handleTargetTap() {
        guard let appearTime = targetAppearTime else { return }
        
        let reactionTime = Date().timeIntervalSince(appearTime)
        reactionTimes.append(reactionTime)
        
        // Calculate score based on reaction time
        let scoreForRound = max(0, Int(1000 - (reactionTime * 500)))
        totalScore += scoreForRound
        
        showTarget = false
        
        if round >= maxRounds {
            showResults = true
        } else {
            round += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startNewRound()
            }
        }
    }
    
    private func handleMissedTarget() {
        reactionTimes.append(2.0) // Max penalty time
        showTarget = false
        
        if round >= maxRounds {
            showResults = true
        } else {
            round += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startNewRound()
            }
        }
    }
}

struct MemoryGameView: View {
    let challenge: GameChallenge
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var sequence = [Int]()
    @State private var playerSequence = [Int]()
    @State private var showingSequence = false
    @State private var currentSequenceIndex = 0
    @State private var level = 1
    @State private var totalScore = 0
    @State private var gamePhase = GamePhase.preparing
    @State private var highlightedButton: Int? = nil
    @State private var isCorrect: Bool? = nil
    
    private let maxLevel = 5
    private let colors = [
        Color(hex: "28a809"), // Green
        Color(hex: "d17305"), // Orange  
        Color(hex: "e6053a"), // Red
        Color.blue           // Blue
    ]
    
    enum GamePhase {
        case preparing
        case showingSequence
        case playerInput
        case feedback
        case completed
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Memory Challenge")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Watch the sequence, then repeat it!")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    Text("Level \(level)/\(maxLevel)")
                        .font(.headline)
                        .foregroundColor(Color(hex: "28a809"))
                    
                    Text("Score: \(totalScore)")
                        .font(.headline)
                        .foregroundColor(Color(hex: "d17305"))
                }
            }
            
            // Status Text
            statusText
            
            // Game Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    memoryButton(index: index)
                }
            }
            .padding(.horizontal, 40)
            
            // Progress Indicator
            if gamePhase == .showingSequence {
                HStack(spacing: 8) {
                    ForEach(0..<sequence.count, id: \.self) { index in
                        Circle()
                            .fill(index < currentSequenceIndex ? Color(hex: "28a809") : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            
            if gamePhase == .completed {
                completionView
            }
        }
        .onAppear {
            startNewLevel()
        }
    }
    
    private var statusText: some View {
        Group {
            switch gamePhase {
            case .preparing:
                Text("Get ready...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            case .showingSequence:
                Text("Watch the sequence")
                    .font(.headline)
                    .foregroundColor(Color(hex: "28a809"))
            case .playerInput:
                Text("Repeat the sequence")
                    .font(.headline)
                    .foregroundColor(Color(hex: "d17305"))
            case .feedback:
                Text(isCorrect == true ? "Correct!" : "Wrong sequence")
                    .font(.headline)
                    .foregroundColor(isCorrect == true ? Color(hex: "28a809") : Color(hex: "e6053a"))
            case .completed:
                Text("Challenge Complete!")
                    .font(.headline)
                    .foregroundColor(Color(hex: "28a809"))
            }
        }
        .animation(.easeInOut, value: gamePhase)
    }
    
    private func memoryButton(index: Int) -> some View {
        Button {
            handleButtonTap(index)
        } label: {
            RoundedRectangle(cornerRadius: 16)
                .fill(buttonColor(for: index))
                .frame(height: 100)
                .overlay(
                    Text("\(index + 1)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                )
                .scaleEffect(highlightedButton == index ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: highlightedButton)
        }
        .disabled(gamePhase != .playerInput)
    }
    
    private func buttonColor(for index: Int) -> Color {
        if highlightedButton == index {
            return colors[index]
        } else if gamePhase == .playerInput {
            return Color.gray.opacity(0.3)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 16) {
            Text("Final Score: \(totalScore)")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "28a809"))
            
            Text("You completed \(level - 1) levels!")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Continue") {
                gameViewModel.completeCurrentChallenge(withScore: totalScore)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
        )
    }
    
    private func startNewLevel() {
        gamePhase = .preparing
        playerSequence = []
        currentSequenceIndex = 0
        highlightedButton = nil
        isCorrect = nil
        
        // Generate sequence (length increases with level)
        let sequenceLength = min(2 + level, 8)
        sequence = (0..<sequenceLength).map { _ in Int.random(in: 0..<4) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSequence()
        }
    }
    
    private func showSequence() {
        gamePhase = .showingSequence
        currentSequenceIndex = 0
        
        showNextInSequence()
    }
    
    private func showNextInSequence() {
        guard currentSequenceIndex < sequence.count else {
            // Sequence shown completely
            gamePhase = .playerInput
            return
        }
        
        let buttonIndex = sequence[currentSequenceIndex]
        highlightedButton = buttonIndex
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            highlightedButton = nil
            currentSequenceIndex += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showNextInSequence()
            }
        }
    }
    
    private func handleButtonTap(_ index: Int) {
        guard gamePhase == .playerInput else { return }
        
        playerSequence.append(index)
        highlightedButton = index
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            highlightedButton = nil
        }
        
        // Check if player sequence matches so far
        if playerSequence.count <= sequence.count {
            let isCurrentlyCorrect = playerSequence == Array(sequence.prefix(playerSequence.count))
            
            if !isCurrentlyCorrect {
                // Wrong sequence
                isCorrect = false
                gamePhase = .feedback
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    gamePhase = .completed
                }
            } else if playerSequence.count == sequence.count {
                // Completed level correctly
                isCorrect = true
                gamePhase = .feedback
                
                let levelScore = level * 200
                totalScore += levelScore
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if level >= maxLevel {
                        gamePhase = .completed
                    } else {
                        level += 1
                        startNewLevel()
                    }
                }
            }
        }
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "28a809"), Color(hex: "d17305")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Color(hex: "28a809"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "28a809"), lineWidth: 2)
                    .background(Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ARButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color(hex: "e6053a"), Color(hex: "d17305")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct FuturisticProgressViewStyle: ProgressViewStyle {
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
                .frame(width: CGFloat(progress) * 200, height: 8)
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .frame(maxWidth: 200)
    }
}

#Preview {
    GameView()
}
