//
//  OnboardingViewModel.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var username: String = ""
    @Published var selectedSkillLevel: SkillLevel = .beginner
    @Published var selectedAvatar: String = "person.circle.fill"
    @Published var permissionsGranted: [Permission: Bool] = [:]
    @AppStorage("isCompleted") var isCompleted: Bool = false
    @Published var showingPermissionAlert: Bool = false
    @Published var currentPermissionRequest: Permission?
    
    private let totalSteps = 5
    
    var progress: Double {
        Double(currentStep.rawValue) / Double(totalSteps)
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .tutorial:
            return true
        case .personalization:
            return !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .skillSelection:
            return true
        case .permissions:
            return true // Optional permissions
        case .completed:
            return false
        }
    }
    
    // MARK: - Onboarding Steps
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 1
        case tutorial = 2
        case personalization = 3
        case skillSelection = 4
        case permissions = 5
        case completed = 6
        
        var title: String {
            switch self {
            case .welcome:
                return "Welcome to SportPulse Avi"
            case .tutorial:
                return "How to Play"
            case .personalization:
                return "Create Your Profile"
            case .skillSelection:
                return "Choose Your Level"
            case .permissions:
                return "Enable Features"
            case .completed:
                return "You're Ready!"
            }
        }
        
        var subtitle: String {
            switch self {
            case .welcome:
                return "Get ready for an immersive sports gaming experience"
            case .tutorial:
                return "Learn the core gameplay mechanics"
            case .personalization:
                return "Customize your gaming identity"
            case .skillSelection:
                return "Select your preferred difficulty"
            case .permissions:
                return "Unlock AR challenges and social features"
            case .completed:
                return "Let's start your sports adventure!"
            }
        }
    }
    
    // MARK: - Permissions
    enum Permission: String, CaseIterable {
        case camera = "Camera"
        case notifications = "Notifications"
        case location = "Location"
        
        var description: String {
            switch self {
            case .camera:
                return "Required for AR challenges and immersive gameplay"
            case .notifications:
                return "Get notified about achievements and challenges"
            case .location:
                return "Enhanced AR experiences based on your environment"
            }
        }
        
        var iconName: String {
            switch self {
            case .camera:
                return "camera.fill"
            case .notifications:
                return "bell.fill"
            case .location:
                return "location.fill"
            }
        }
        
        var isRequired: Bool {
            switch self {
            case .camera:
                return false // AR is optional
            case .notifications:
                return false
            case .location:
                return false
            }
        }
    }
    
    // MARK: - Tutorial Steps
    struct TutorialStep {
        let title: String
        let description: String
        let iconName: String
        let animationName: String?
    }
    
    let tutorialSteps: [TutorialStep] = [
        TutorialStep(
            title: "Sports-Themed Challenges",
            description: "Solve unique puzzles and complete timing challenges inspired by your favorite sports",
            iconName: "sportscourt.fill",
            animationName: "sports_challenge"
        ),
        TutorialStep(
            title: "Real-Time Scoring",
            description: "Earn points based on your performance, speed, and accuracy. Compete for high scores!",
            iconName: "chart.line.uptrend.xyaxis",
            animationName: "scoring_system"
        ),
        TutorialStep(
            title: "AR Challenges",
            description: "Use your device's camera for immersive augmented reality challenges that blend digital and physical worlds",
            iconName: "arkit",
            animationName: "ar_experience"
        ),
        TutorialStep(
            title: "Social Competition",
            description: "Share achievements, compete on leaderboards, and challenge friends to beat your scores",
            iconName: "person.2.fill",
            animationName: "social_features"
        )
    ]
    
    @Published var currentTutorialStep: Int = 0
    
    // MARK: - Avatar Options
    let avatarOptions: [String] = [
        "person.circle.fill",
        "person.crop.circle.fill",
        "person.crop.square.fill",
        "sportscourt.fill",
        "figure.run",
        "figure.basketball",
        "figure.soccer",
        "figure.tennis"
    ]
    
    // MARK: - Navigation
    func nextStep() {
        guard canProceed else { return }
        
        switch currentStep {
        case .welcome:
            currentStep = .tutorial
        case .tutorial:
            currentStep = .personalization
        case .personalization:
            currentStep = .skillSelection
        case .skillSelection:
            currentStep = .permissions
        case .permissions:
            currentStep = .completed
            complete()
        case .completed:
            break
        }
    }
    
    func previousStep() {
        switch currentStep {
        case .welcome:
            break
        case .tutorial:
            currentStep = .welcome
        case .personalization:
            currentStep = .tutorial
        case .skillSelection:
            currentStep = .personalization
        case .permissions:
            currentStep = .skillSelection
        case .completed:
            currentStep = .permissions
        }
    }
    
    func skipToEnd() {
        currentStep = .completed
        complete()
    }
    
    // MARK: - Tutorial Navigation
    func nextTutorialStep() {
        if currentTutorialStep < tutorialSteps.count - 1 {
            currentTutorialStep += 1
        } else {
            nextStep()
        }
    }
    
    func previousTutorialStep() {
        if currentTutorialStep > 0 {
            currentTutorialStep -= 1
        } else {
            previousStep()
        }
    }
    
    // MARK: - Personalization
    func updateUsername(_ newUsername: String) {
        username = newUsername
    }
    
    func selectAvatar(_ avatar: String) {
        selectedAvatar = avatar
    }
    
    func selectSkillLevel(_ skillLevel: SkillLevel) {
        selectedSkillLevel = skillLevel
    }
    
    // MARK: - Permissions
    func requestPermission(_ permission: Permission) {
        currentPermissionRequest = permission
        showingPermissionAlert = true
    }
    
    func handlePermissionResponse(_ granted: Bool) {
        guard let permission = currentPermissionRequest else { return }
        
        permissionsGranted[permission] = granted
        
        // Handle actual permission requests
        switch permission {
        case .camera:
            if granted {
                requestCameraPermission()
            }
        case .notifications:
            if granted {
                requestNotificationPermission()
            }
        case .location:
            if granted {
                requestLocationPermission()
            }
        }
        
        showingPermissionAlert = false
        currentPermissionRequest = nil
    }
    
    private func requestCameraPermission() {
        // This would use AVCaptureDevice.requestAccess
        // For now, we'll simulate the permission
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.permissionsGranted[.camera] = true
        }
    }
    
    private func requestNotificationPermission() {
        // This would use UNUserNotificationCenter
        // For now, we'll simulate the permission
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.permissionsGranted[.notifications] = true
        }
    }
    
    private func requestLocationPermission() {
        // This would use CLLocationManager
        // For now, we'll simulate the permission
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.permissionsGranted[.location] = true
        }
    }
    
    // MARK: - Completion
    func complete() {
        isCompleted = true
        
        // Create user profile with onboarding data
        let profile = UserProfile(
            username: username,
            avatar: selectedAvatar,
            preferences: GamePreferences(
                soundEnabled: true,
                musicEnabled: true,
                hapticFeedbackEnabled: true,
                notificationsEnabled: permissionsGranted[.notifications] ?? false,
                preferredSkillLevel: selectedSkillLevel,
                autoSaveEnabled: true,
                accessibilityMode: false,
                colorBlindSupport: false
            )
        )
        
        // Save to UserDefaults to mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
        UserDefaults.standard.set(try? JSONEncoder().encode(profile), forKey: "UserProfile")
    }
    
    // MARK: - Validation
    func validateUsername(_ username: String) -> String? {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Username cannot be empty"
        }
        
        if trimmed.count < 3 {
            return "Username must be at least 3 characters"
        }
        
        if trimmed.count > 20 {
            return "Username must be less than 20 characters"
        }
        
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        if trimmed.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return "Username can only contain letters, numbers, _ and -"
        }
        
        return nil
    }
    
    // MARK: - Animation Helpers
    func getStepAnimation() -> Animation {
        return .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    }
    
    func getTutorialAnimation() -> Animation {
        return .easeInOut(duration: 0.5)
    }
    
    // MARK: - Accessibility
    func getAccessibilityLabel(for step: OnboardingStep) -> String {
        return "\(step.title). Step \(step.rawValue) of \(totalSteps). \(step.subtitle)"
    }
    
    func getPermissionAccessibilityLabel(for permission: Permission) -> String {
        let status = permissionsGranted[permission] ?? false ? "granted" : "not granted"
        return "\(permission.rawValue) permission \(status). \(permission.description)"
    }
}
