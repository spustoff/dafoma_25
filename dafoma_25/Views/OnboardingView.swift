//
//  OnboardingView.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var currentPage = 0
    @State private var username = ""
    @State private var selectedSkillLevel = SkillLevel.beginner
    @State private var selectedAvatar = "person.circle.fill"
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Background
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
            
            // Content
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator
                
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(for: pages[index], index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Navigation
                navigationButtons
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index <= currentPage ? Color(hex: "28a809") : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    // MARK: - Page View
    @ViewBuilder
    private func pageView(for page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.iconName)
                .font(.system(size: 80, weight: .medium))
                .foregroundColor(Color(hex: "28a809"))
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 32)
            
            // Interactive Content
            if index == 1 {
                usernameSetupView
            } else if index == 2 {
                skillLevelSetupView
            } else if index == 3 {
                avatarSetupView
            }
            
            Spacer()
        }
    }
    
    // MARK: - Username Setup
    private var usernameSetupView: some View {
        VStack(spacing: 16) {
            Text("What should we call you?")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Enter your username", text: $username)
                .textFieldStyle(OnboardingTextFieldStyle())
                .submitLabel(.next)
                .onSubmit {
                    if !username.isEmpty {
                        nextPage()
                    }
                }
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Skill Level Setup
    private var skillLevelSetupView: some View {
        VStack(spacing: 20) {
            Text("Choose your skill level")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(SkillLevel.allCases, id: \.self) { level in
                    Button {
                        selectedSkillLevel = level
                    } label: {
                        HStack(spacing: 16) {
                            // Selection indicator
                            Image(systemName: selectedSkillLevel == level ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(selectedSkillLevel == level ? Color(hex: "28a809") : .secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            // Difficulty stars
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(level.difficultyMultiplier * 2.5) ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "d17305"))
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedSkillLevel == level ? Color(hex: "28a809").opacity(0.2) : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedSkillLevel == level ? Color(hex: "28a809") : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Avatar Setup
    private var avatarSetupView: some View {
        VStack(spacing: 20) {
            Text("Pick your avatar")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(["person.circle.fill", "gamecontroller.fill", "star.circle.fill", "crown.fill", "bolt.circle.fill", "heart.circle.fill", "flame.circle.fill", "sparkles"], id: \.self) { icon in
                    Button {
                        selectedAvatar = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.system(size: 32))
                            .foregroundColor(selectedAvatar == icon ? .white : .secondary)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(selectedAvatar == icon ? Color(hex: "28a809") : Color.gray.opacity(0.2))
                            )
                            .scaleEffect(selectedAvatar == icon ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedAvatar)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back Button
            if currentPage > 0 {
                Button("Back") {
                    previousPage()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            // Next/Finish Button
            Button(currentPage == pages.count - 1 ? "Get Started!" : "Next") {
                if currentPage == pages.count - 1 {
                    finishOnboarding()
                } else {
                    nextPage()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isNextButtonDisabled)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }
    
    // MARK: - Helper Properties
    private var isNextButtonDisabled: Bool {
        switch currentPage {
        case 1: return username.isEmpty
        default: return false
        }
    }
    
    // MARK: - Navigation Methods
    private func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage -= 1
            }
        }
    }
    
    private func finishOnboarding() {
        // Save user preferences
        gameViewModel.userProfile.username = username
        gameViewModel.userProfile.avatar = selectedAvatar
        gameViewModel.userProfile.preferences.preferredSkillLevel = selectedSkillLevel
        
        gameViewModel.saveUserProfile()
        
        // Mark onboarding as completed
        let dataService = DataService()
        dataService.markOnboardingCompleted()
        
        // Navigate to main game
        gameViewModel.gameSession.currentState = .menu
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let description: String
    let iconName: String
    
    static let allPages = [
        OnboardingPage(
            title: "Welcome to SportPulse Avi",
            description: "Experience the future of sports gaming with immersive challenges, AR interactions, and competitive gameplay.",
            iconName: "sportscourt.fill"
        ),
        OnboardingPage(
            title: "Create Your Profile",
            description: "Set up your gaming profile to track your progress and compete with players worldwide.",
            iconName: "person.crop.circle.badge.plus"
        ),
        OnboardingPage(
            title: "Choose Your Level",
            description: "Select your skill level to get challenges that match your gaming experience and keep you engaged.",
            iconName: "slider.horizontal.3"
        ),
        OnboardingPage(
            title: "Personalize Your Avatar",
            description: "Pick an avatar that represents you in the game and on leaderboards.",
            iconName: "person.circle.fill"
        ),
        OnboardingPage(
            title: "Ready to Play!",
            description: "You're all set! Start with any challenge type and work your way up to become a SportPulse champion.",
            iconName: "flag.checkered"
        )
    ]
}

// MARK: - Custom Text Field Style
struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "28a809").opacity(0.5), lineWidth: 2)
                    )
            )
            .foregroundColor(.white)
            .font(.headline)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(GameViewModel())
}
