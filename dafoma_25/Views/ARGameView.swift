//
//  ARGameView.swift
//  SportPulse Avi
//
//  Created by AI Assistant on 1/20/25.
//

import SwiftUI
import ARKit
import RealityKit
import AVFoundation

struct ARGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @StateObject private var arViewModel = ARGameViewModel()
    @State private var showingInstructions = true
    @State private var showingPermissionAlert = false
    
    var body: some View {
        ZStack {
            // AR View
            if arViewModel.isARSupported && arViewModel.hasPermission {
                ARViewContainer(arViewModel: arViewModel)
                    .ignoresSafeArea()
            } else {
                // Fallback view for devices without AR
                arUnavailableView
            }
            
            // UI Overlay
            VStack {
                // Top HUD
                topHUD
                
                Spacer()
                
                // Bottom Controls
                bottomControls
            }
            .padding(24)
        }
        .onAppear {
            arViewModel.setupAR()
        }
        .onDisappear {
            arViewModel.stopAR()
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel") {
                gameViewModel.gameSession.currentState = .menu
            }
        } message: {
            Text("AR challenges require camera access to create immersive experiences.")
        }
        .alert("AR Instructions", isPresented: $showingInstructions) {
            Button("Start Challenge") {
                arViewModel.startChallenge()
            }
        } message: {
            Text("Move your device to scan the environment, then tap on virtual targets as they appear!")
        }
    }
    
    // MARK: - Top HUD
    private var topHUD: some View {
        HStack {
            // Back Button
            Button {
                gameViewModel.gameSession.currentState = .menu
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.6))
                    )
            }
            
            Spacer()
            
            // Score & Timer
            VStack(spacing: 4) {
                Text("Score: \(arViewModel.currentScore)")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "28a809"))
                
                if arViewModel.timeRemaining > 0 {
                    Text("Time: \(Int(arViewModel.timeRemaining))s")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
            )
            
            Spacer()
            
            // Instructions Button
            Button {
                showingInstructions = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.6))
                    )
            }
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 16) {
            // AR Status
            HStack(spacing: 8) {
                Circle()
                    .fill(arViewModel.isTracking ? Color(hex: "28a809") : Color(hex: "e6053a"))
                    .frame(width: 8, height: 8)
                
                Text(arViewModel.isTracking ? "AR Tracking Active" : "Move device to track environment")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.6))
            )
            
            // Challenge Progress
            if arViewModel.isPlaying {
                VStack(spacing: 8) {
                    Text("Targets Hit: \(arViewModel.targetsHit)/\(arViewModel.totalTargets)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ProgressView(value: Double(arViewModel.targetsHit), total: Double(arViewModel.totalTargets))
                        .progressViewStyle(FuturisticProgressViewStyle())
                        .frame(maxWidth: 200)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.6))
                )
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                if !arViewModel.isPlaying {
                    Button("Start AR Challenge") {
                        arViewModel.startChallenge()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button("End Challenge") {
                        arViewModel.endChallenge()
                        let score = arViewModel.currentScore
                        gameViewModel.completeCurrentChallenge(withScore: score)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
    }
    
    // MARK: - AR Unavailable View
    private var arUnavailableView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "arkit")
                    .font(.system(size: 80))
                    .foregroundColor(.secondary)
                
                Text("AR Not Available")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(arViewModel.unavailabilityReason)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button("Back to Menu") {
                gameViewModel.gameSession.currentState = .menu
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
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
    }
}

// MARK: - ARViewContainer
struct ARViewContainer: UIViewRepresentable {
    let arViewModel: ARGameViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arViewModel.setupARView(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update AR view if needed
    }
}

// MARK: - AR Game ViewModel
class ARGameViewModel: NSObject, ObservableObject {
    @Published var isARSupported = false
    @Published var hasPermission = false
    @Published var isTracking = false
    @Published var isPlaying = false
    @Published var currentScore = 0
    @Published var targetsHit = 0
    @Published var totalTargets = 10
    @Published var timeRemaining: TimeInterval = 60
    
    private var arView: ARView?
    private var gameTimer: Timer?
    private var targetEntities: [ModelEntity] = []
    
    var unavailabilityReason: String {
        if !isARSupported {
            return "This device doesn't support AR features. AR challenges require a device with ARKit support."
        } else if !hasPermission {
            return "Camera permission is required for AR challenges. Please enable camera access in Settings."
        }
        return ""
    }
    
    override init() {
        super.init()
        checkARSupport()
        checkPermissions()
    }
    
    // MARK: - Setup
    private func checkARSupport() {
        isARSupported = ARWorldTrackingConfiguration.isSupported
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .notDetermined:
            requestCameraPermission()
        default:
            hasPermission = false
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
            }
        }
    }
    
    func setupAR() {
        guard isARSupported && hasPermission else { return }
        // AR setup will be handled in setupARView
    }
    
    func setupARView(_ arView: ARView) {
        self.arView = arView
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        arView.session.run(configuration)
        arView.session.delegate = self
        
        // Add lighting
        arView.environment.lighting.resource = try? EnvironmentResource.load(named: "studio")
        
        // Enable people occlusion if supported
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
    }
    
    func stopAR() {
        arView?.session.pause()
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    // MARK: - Game Logic
    func startChallenge() {
        guard arView != nil else { return }
        
        isPlaying = true
        currentScore = 0
        targetsHit = 0
        timeRemaining = 60
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Spawn initial targets
        spawnTargets()
    }
    
    func endChallenge() {
        isPlaying = false
        gameTimer?.invalidate()
        gameTimer = nil
        
        // Remove all targets
        targetEntities.forEach { entity in
            entity.removeFromParent()
        }
        targetEntities.removeAll()
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            endChallenge()
        }
    }
    
    private func spawnTargets() {
        guard let arView = arView, isPlaying else { return }
        
        // Create target entities
        for _ in 0..<3 { // Spawn 3 targets at a time
            let targetEntity = createTargetEntity()
            
            // Position targets in front of the user
            let distance: Float = Float.random(in: 1.5...3.0)
            let angle = Float.random(in: -Float.pi/4...Float.pi/4)
            let height = Float.random(in: 0.5...2.0)
            
            let x = sin(angle) * distance
            let z = -cos(angle) * distance
            
            targetEntity.position = SIMD3<Float>(x, height, z)
            
            // Add to scene
            let anchor = AnchorEntity(world: targetEntity.position)
            anchor.addChild(targetEntity)
            arView.scene.addAnchor(anchor)
            
            targetEntities.append(targetEntity)
            
            // Add tap gesture
            targetEntity.generateCollisionShapes(recursive: true)
            arView.installGestures([.translation, .rotation], for: targetEntity)
        }
        
        // Schedule next spawn
        if targetsHit < totalTargets {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.spawnTargets()
            }
        }
    }
    
    private func createTargetEntity() -> ModelEntity {
        // Create a glowing sphere target
        let mesh = MeshResource.generateSphere(radius: 0.1)
        var material = UnlitMaterial(color: .green)
        material.color = .init(tint: .green, texture: nil)
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Add glow effect (iOS 15.6 compatible)
        if #available(iOS 18.0, *) {
            entity.components.set(OpacityComponent(opacity: 0.8))
        }
        
        // Simple floating animation (iOS 15.6 compatible)
        var transform = entity.transform
        transform.translation.y += 0.1
        entity.move(to: transform, relativeTo: entity.parent, duration: 1.0)
        
        return entity
    }
    
    func targetTapped(_ entity: ModelEntity) {
        guard isPlaying else { return }
        
        // Remove target
        entity.removeFromParent()
        if let index = targetEntities.firstIndex(of: entity) {
            targetEntities.remove(at: index)
        }
        
        // Update score
        targetsHit += 1
        currentScore += 100
        
        // Add bonus for speed
        let timeBonus = Int(timeRemaining / 60.0 * 50)
        currentScore += timeBonus
        
        // Check if challenge is complete
        if targetsHit >= totalTargets {
            endChallenge()
        }
    }
}

// MARK: - ARSessionDelegate
extension ARGameViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // Handle anchor additions if needed
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // Handle anchor updates if needed
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        // Handle anchor removals if needed
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        DispatchQueue.main.async {
            switch camera.trackingState {
            case .normal:
                self.isTracking = true
            case .limited, .notAvailable:
                self.isTracking = false
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isTracking = false
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.isTracking = false
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Restart the session if needed
        if let arView = arView {
            let configuration = ARWorldTrackingConfiguration()
            arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
}

#Preview {
    ARGameView()
        .environmentObject(GameViewModel())
}
