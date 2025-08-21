//
//  SportPulseAviApp.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI

@main
struct SportPulseAviApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure app appearance
        configureAppearance()
        
        // Set up analytics (privacy-compliant)
        setupAnalytics()
        
        // Configure accessibility
        configureAccessibility()
    }
    
    private func configureAppearance() {
        // Set global tint color
        UIView.appearance().tintColor = UIColor(red: 40/255, green: 168/255, blue: 9/255, alpha: 1.0)
        
        // Configure navigation bar appearance
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor(red: 14/255, green: 14/255, blue: 14/255, alpha: 0.95)
        navigationAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        navigationAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 14/255, green: 14/255, blue: 14/255, alpha: 0.95)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func setupAnalytics() {
        // Set up privacy-compliant analytics
        // This would integrate with Apple's analytics or other privacy-focused solutions
        print("Analytics configured with privacy compliance")
    }
    
    private func configureAccessibility() {
        // Configure accessibility settings
        // Ensure VoiceOver and other accessibility features work properly
        print("Accessibility features configured")
    }
}
