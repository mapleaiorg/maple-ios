import SwiftUI
import RealityKit
import Combine

struct CompanionView: View {
    @EnvironmentObject var viewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAvatarPicker = false
    @State private var showingPersonalityEditor = false
    @State private var selected3DModel = "robot"
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Swipeable content
                    TabView(selection: $currentPage) {
                        // Page 1: Full screen 3D Companion
                        ZStack {
                            Companion3DView(modelName: $selected3DModel)
                                .ignoresSafeArea(edges: .bottom)
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: { showingAvatarPicker.toggle() }) {
                                        Label("Change Avatar", systemImage: "pencil.circle.fill")
                                            .font(.caption)
                                            .padding(8)
                                            .background(Color.black.opacity(0.6))
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding()
                                
                                Spacer()
                                
                                // Quick actions bar at bottom
                                HStack(spacing: 30) {
                                    QuickActionButton(icon: "gamecontroller.fill", color: .purple) {
                                        viewModel.interact(action: .play)
                                    }
                                    QuickActionButton(icon: "leaf.fill", color: .green) {
                                        viewModel.interact(action: .feed)
                                    }
                                    QuickActionButton(icon: "bubble.left.fill", color: .blue) {
                                        viewModel.interact(action: .chat)
                                    }
                                    QuickActionButton(icon: "moon.fill", color: .indigo) {
                                        viewModel.interact(action: .rest)
                                    }
                                }
                                .padding()
                                .background(
                                    Capsule()
                                        .fill(Color(.systemBackground).opacity(0.9))
                                        .shadow(color: .black.opacity(0.1), radius: 10)
                                )
                                .padding(.bottom, 30)
                            }
                        }
                        .tag(0)
                        
                        // Page 2: Stats and Status
                        ScrollView {
                            VStack(spacing: 20) {
                                CompanionStatsView()
                                PersonalityTraitsView()
                                    .onTapGesture {
                                        showingPersonalityEditor.toggle()
                                    }
                            }
                            .padding()
                        }
                        .tag(1)
                        
                        // Page 3: Activities and History
                        ScrollView {
                            VStack(spacing: 20) {
                                InteractiveActionsGrid()
                                
                                // Activity History
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Recent Activities")
                                        .font(.headline)
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(0..<10) { index in
                                        ActivityRow(
                                            icon: ["gamecontroller", "leaf", "bubble.left", "moon"].randomElement()!,
                                            title: ["Played together", "Fed Maple", "Had a chat", "Rest time"].randomElement()!,
                                            time: "\(index * 5 + 5) minutes ago"
                                        )
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                                )
                            }
                            .padding()
                        }
                        .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Companion")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAvatarPicker) {
                AvatarPickerView(selectedModel: $selected3DModel)
            }
            .sheet(isPresented: $showingPersonalityEditor) {
                PersonalityEditorView()
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: "\(icon).fill")
                .font(.body)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Companion View Model
class CompanionViewModel: ObservableObject {
    @Published var companionState = CompanionState(
        mood: .happy,
        energy: 85,
        lastInteraction: Date(),
        personality: CompanionState.PersonalityTraits(
            friendliness: 0.9,
            helpfulness: 0.85,
            humor: 0.7,
            empathy: 0.95
        )
    )
    
    @Published var selectedAvatar = "robot"
    @Published var companionName = "Maple"
    @Published var currentAnimation: CompanionAnimation = .idle
    @Published var isSpeaking = false
    
    private let ttsManager = TTSManager()
    
    var currentMoodText: String {
        switch companionState.mood {
        case .happy: return "Happy & Energetic"
        case .neutral: return "Calm & Ready"
        case .thoughtful: return "Deep in Thought"
        case .excited: return "Super Excited!"
        case .sleepy: return "A bit Sleepy"
        }
    }
    
    func interact(action: CompanionAction) {
        // Update companion state based on interaction
        companionState.lastInteraction = Date()
        
        switch action {
        case .play:
            companionState.energy = max(0, companionState.energy - 10)
            companionState.mood = .excited
            currentAnimation = .jump
            speak("Let's play together! This is so much fun!")
        case .feed:
            companionState.energy = min(100, companionState.energy + 20)
            companionState.mood = .happy
            currentAnimation = .happy
            speak("Yummy! Thank you for the energy boost!")
        case .chat:
            companionState.mood = .thoughtful
            currentAnimation = .talking
            speak("I'd love to chat with you. What's on your mind?")
        case .rest:
            companionState.energy = min(100, companionState.energy + 30)
            companionState.mood = .sleepy
            currentAnimation = .sleeping
            speak("A little rest sounds perfect. Sweet dreams!")
        }
        
        // Reset to idle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.currentAnimation = .idle
        }
    }
    
    func speak(_ text: String) {
        isSpeaking = true
        currentAnimation = .talking
        
        // Send to TTS backend
        ttsManager.synthesizeSpeech(text: text) { [weak self] success in
            DispatchQueue.main.async {
                self?.isSpeaking = false
                if self?.currentAnimation == .talking {
                    self?.currentAnimation = .idle
                }
            }
        }
    }
    
    enum CompanionAction {
        case play, feed, chat, rest
    }
    
    enum CompanionAnimation {
        case idle, happy, jump, talking, sleeping
    }
}

// MARK: - TTS Manager
class TTSManager {
    // This would connect to your backend LLM TTS service
    func synthesizeSpeech(text: String, completion: @escaping (Bool) -> Void) {
        // Simulate TTS API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // In production, this would:
            // 1. Send text to your backend TTS service
            // 2. Receive audio data
            // 3. Play the audio
            print("TTS: \(text)")
            completion(true)
        }
    }
}

// MARK: - 3D Companion View with RealityKit
struct Companion3DView: UIViewRepresentable {
    @Binding var modelName: String
    @EnvironmentObject var viewModel: CompanionViewModel
    
    class Coordinator: NSObject {
        var parent: Companion3DView
        var cancellables = Set<AnyCancellable>()
        var currentEntity: Entity?
        var arView: ARView?
        
        init(_ parent: Companion3DView) {
            self.parent = parent
        }
        
        func loadModel(named: String) {
            guard let arView = arView else { return }
            
            // Remove existing model
            arView.scene.anchors.forEach { anchor in
                if anchor.name == "companion_anchor" {
                    arView.scene.removeAnchor(anchor)
                }
            }
            
            // Create anchor for the model
            let anchor = AnchorEntity(world: .zero)
            anchor.name = "companion_anchor"
            
            // Create a simple robot model based on the name
            let modelEntity = createRobotModel(variant: named)
            
            // Configure the model
            modelEntity.name = "companion_model"
            modelEntity.position = [0, -0.5, 0]
            modelEntity.scale = [1, 1, 1]
            
            // Store reference for animations
            currentEntity = modelEntity
            
            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)
            
            // Add idle animation
            addIdleAnimation(to: modelEntity)
        }
        
        private func createRobotModel(variant: String) -> ModelEntity {
            // Create a simple robot using primitive shapes
            let robotEntity = ModelEntity()
            
            // Determine color based on variant
            let color: UIColor
            switch variant {
            case "robot_blue": color = .systemBlue
            case "robot_green": color = .systemGreen
            case "robot_purple": color = .systemPurple
            case "robot_orange": color = .systemOrange
            case "robot_pink": color = .systemPink
            default: color = .systemOrange // Default Maple color
            }
            
            // Head
            let headMesh = MeshResource.generateBox(size: [0.4, 0.4, 0.4], cornerRadius: 0.1)
            let headMaterial = SimpleMaterial(color: color, roughness: 0.3, isMetallic: true)
            let head = ModelEntity(mesh: headMesh, materials: [headMaterial])
            head.position = [0, 0.8, 0]
            
            // Eyes
            let eyeMesh = MeshResource.generateSphere(radius: 0.05)
            let eyeMaterial = SimpleMaterial(color: .white, isMetallic: false)
            let leftEye = ModelEntity(mesh: eyeMesh, materials: [eyeMaterial])
            leftEye.position = [-0.1, 0.05, 0.2]
            let rightEye = ModelEntity(mesh: eyeMesh, materials: [eyeMaterial])
            rightEye.position = [0.1, 0.05, 0.2]
            
            // Eye pupils
            let pupilMesh = MeshResource.generateSphere(radius: 0.02)
            let pupilMaterial = SimpleMaterial(color: .black, isMetallic: false)
            let leftPupil = ModelEntity(mesh: pupilMesh, materials: [pupilMaterial])
            leftPupil.position = [0, 0, 0.03]
            let rightPupil = ModelEntity(mesh: pupilMesh, materials: [pupilMaterial])
            rightPupil.position = [0, 0, 0.03]
            
            leftEye.addChild(leftPupil)
            rightEye.addChild(rightPupil)
            head.addChild(leftEye)
            head.addChild(rightEye)
            
            // Body
            let bodyMesh = MeshResource.generateBox(size: [0.5, 0.6, 0.3], cornerRadius: 0.1)
            let bodyMaterial = SimpleMaterial(color: color.withAlphaComponent(0.9), roughness: 0.4, isMetallic: true)
            let body = ModelEntity(mesh: bodyMesh, materials: [bodyMaterial])
            body.position = [0, 0.3, 0]
            
            // Arms
            let armMesh = MeshResource.generateCylinder(height: 0.4, radius: 0.08)
            let leftArm = ModelEntity(mesh: armMesh, materials: [headMaterial])
            leftArm.position = [-0.35, 0.3, 0]
            leftArm.orientation = simd_quatf(angle: .pi / 6, axis: [0, 0, 1])
            
            let rightArm = ModelEntity(mesh: armMesh, materials: [headMaterial])
            rightArm.position = [0.35, 0.3, 0]
            rightArm.orientation = simd_quatf(angle: -.pi / 6, axis: [0, 0, 1])
            
            // Legs
            let legMesh = MeshResource.generateCylinder(height: 0.5, radius: 0.1)
            let leftLeg = ModelEntity(mesh: legMesh, materials: [bodyMaterial])
            leftLeg.position = [-0.15, -0.15, 0]
            
            let rightLeg = ModelEntity(mesh: legMesh, materials: [bodyMaterial])
            rightLeg.position = [0.15, -0.15, 0]
            
            // Antenna
            let antennaMesh = MeshResource.generateCylinder(height: 0.2, radius: 0.02)
            let antennaMaterial = SimpleMaterial(color: .systemGray, isMetallic: true)
            let antenna = ModelEntity(mesh: antennaMesh, materials: [antennaMaterial])
            antenna.position = [0, 0.3, 0]
            
            let antennaTopMesh = MeshResource.generateSphere(radius: 0.04)
            let antennaTop = ModelEntity(mesh: antennaTopMesh, materials: [eyeMaterial])
            antennaTop.position = [0, 0.1, 0]
            antenna.addChild(antennaTop)
            head.addChild(antenna)
            
            // Assemble robot
            robotEntity.addChild(head)
            robotEntity.addChild(body)
            robotEntity.addChild(leftArm)
            robotEntity.addChild(rightArm)
            robotEntity.addChild(leftLeg)
            robotEntity.addChild(rightLeg)
            
            return robotEntity
        }
        
        private func addIdleAnimation(to entity: Entity) {
            // Add a gentle floating animation
            let originalY = entity.position.y
            
            Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
                var transform = entity.transform
                transform.translation.y = originalY + 0.05
                entity.move(to: transform, relativeTo: entity.parent, duration: 2, timingFunction: .easeInOut)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    transform.translation.y = originalY - 0.05
                    entity.move(to: transform, relativeTo: entity.parent, duration: 2, timingFunction: .easeInOut)
                }
            }
            
            // Add rotation animation
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                entity.transform.rotation *= simd_quatf(angle: 0.01, axis: [0, 1, 0])
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        
        // Configure the AR view for non-AR 3D display
        arView.environment.background = .color(.clear)
        
        // Setup camera
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        cameraEntity.position = [0, 0.5, 3]
        cameraEntity.look(at: [0, 0.3, 0], from: cameraEntity.position, relativeTo: nil)
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)
        
        // Add lighting
        setupLighting(in: arView)
        
        // Load initial model
        context.coordinator.loadModel(named: modelName)
        
        // Add gesture recognizers
        setupGestures(for: arView, coordinator: context.coordinator)
        
        // Observe animation changes
        viewModel.$currentAnimation
            .sink { animation in
                context.coordinator.playAnimation(animation)
            }
            .store(in: &context.coordinator.cancellables)
        
        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        // Update model when selection changes
        if context.coordinator.parent.modelName != modelName {
            context.coordinator.parent.modelName = modelName
            context.coordinator.loadModel(named: modelName)
        }
    }
    
    private func setupLighting(in arView: ARView) {
        // Add directional light
        let directionalLight = DirectionalLight()
        directionalLight.light.color = .white
        directionalLight.light.intensity = 2000
        directionalLight.light.isRealWorldProxy = true
        directionalLight.look(at: [0, 0, 0], from: [2, 3, 2], relativeTo: nil)
        
        let lightAnchor = AnchorEntity(world: .zero)
        lightAnchor.addChild(directionalLight)
        arView.scene.addAnchor(lightAnchor)
        
        // Add point light for better illumination
        let pointLight = PointLight()
        pointLight.light.color = .white
        pointLight.light.intensity = 1000
        pointLight.light.attenuationRadius = 5
        pointLight.position = [0, 2, 2]
        
        let pointLightAnchor = AnchorEntity(world: .zero)
        pointLightAnchor.addChild(pointLight)
        arView.scene.addAnchor(pointLightAnchor)
    }
    
    private func setupGestures(for arView: ARView, coordinator: Coordinator) {
        // Add pan gesture for rotation
        let panGesture = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        // Add pinch gesture for scale
        let pinchGesture = UIPinchGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
    }
}

// MARK: - Gesture Handlers
extension Companion3DView.Coordinator {
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let entity = currentEntity else { return }
        
        let translation = gesture.translation(in: arView)
        let rotationY = Float(translation.x) * .pi / 180
        
        if gesture.state == .changed {
            entity.transform.rotation *= simd_quatf(angle: rotationY * 0.01, axis: [0, 1, 0])
        }
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let entity = currentEntity else { return }
        
        if gesture.state == .changed {
            let scale = Float(gesture.scale)
            let newScale = entity.scale * SIMD3<Float>(repeating: scale)
            // Limit scale between 0.5 and 2.0
            entity.scale = SIMD3<Float>(
                repeating: min(max(newScale.x, 0.5), 2.0)
            )
            gesture.scale = 1.0
        }
    }
    
    func playAnimation(_ animation: CompanionViewModel.CompanionAnimation) {
        guard let entity = currentEntity else { return }
        
        switch animation {
        case .idle:
            // Return to idle animation
            break
        case .happy:
            // Play happy bounce animation
            let originalScale = entity.scale
            entity.scale = originalScale * 1.2
            entity.move(to: Transform(scale: originalScale), relativeTo: entity.parent, duration: 0.3, timingFunction: .easeOut)
            
        case .jump:
            // Play jump animation
            let originalY = entity.position.y
            var transform = entity.transform
            transform.translation.y = originalY + 0.5
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.4, timingFunction: .easeOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transform.translation.y = originalY
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.4, timingFunction: .easeIn)
            }
            
        case .talking:
            // Play talking animation
            animateTalking(entity: entity, count: 3)
            
        case .sleeping:
            // Play sleeping animation
            animateSleeping(entity: entity)
        }
    }
    
    private func animateTalking(entity: Entity, count: Int) {
        guard count > 0 else { return }
        
        let originalScale = entity.scale
        entity.scale = originalScale * 1.05
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            entity.scale = originalScale * 0.95
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                entity.scale = originalScale
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.animateTalking(entity: entity, count: count - 1)
                }
            }
        }
    }
    
    private func animateSleeping(entity: Entity) {
        let originalScale = entity.scale
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            entity.move(to: Transform(scale: originalScale * 1.02), relativeTo: entity.parent, duration: 2, timingFunction: .easeInOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                entity.move(to: Transform(scale: originalScale * 0.98), relativeTo: entity.parent, duration: 2, timingFunction: .easeInOut)
            }
        }
    }
}

// MARK: - Companion Stats View
struct CompanionStatsView: View {
    @EnvironmentObject var viewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with avatar and name
            HStack(spacing: 16) {
                Circle()
                    .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("🍁")
                            .font(.system(size: 30))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.companionName)
                        .font(.title2)
                        .bold()
                    Text("Last active \(viewModel.companionState.lastInteraction, style: .relative) ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Mood emoji
                Text(moodEmoji(for: viewModel.companionState.mood))
                    .font(.system(size: 40))
            }
            
            // Stats Cards
            HStack(spacing: 12) {
                StatCard(
                    icon: "bolt.fill",
                    title: "Energy",
                    value: "\(viewModel.companionState.energy)%",
                    color: .yellow,
                    progress: Double(viewModel.companionState.energy) / 100
                )
                
                StatCard(
                    icon: "heart.fill",
                    title: "Bond",
                    value: "Strong",
                    color: themeManager.currentTheme.primaryColor,
                    progress: 0.85
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func moodEmoji(for mood: CompanionState.CompanionMood) -> String {
        switch mood {
        case .happy: return "😊"
        case .neutral: return "😐"
        case .thoughtful: return "🤔"
        case .excited: return "🤩"
        case .sleepy: return "😴"
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.2))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Interactive Actions Grid
struct InteractiveActionsGrid: View {
    @EnvironmentObject var viewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ActionCard(
                    title: "Play",
                    icon: "gamecontroller.fill",
                    description: "Have fun together",
                    gradient: Gradient(colors: [.purple, .pink]),
                    action: { viewModel.interact(action: .play) }
                )
                
                ActionCard(
                    title: "Feed",
                    icon: "leaf.fill",
                    description: "Give energy boost",
                    gradient: Gradient(colors: [.green, .mint]),
                    action: { viewModel.interact(action: .feed) }
                )
                
                ActionCard(
                    title: "Chat",
                    icon: "bubble.left.fill",
                    description: "Start conversation",
                    gradient: Gradient(colors: [.blue, .cyan]),
                    action: { viewModel.interact(action: .chat) }
                )
                
                ActionCard(
                    title: "Rest",
                    icon: "moon.fill",
                    description: "Take a break",
                    gradient: Gradient(colors: [.indigo, .purple]),
                    action: { viewModel.interact(action: .rest) }
                )
            }
        }
    }
}

// MARK: - Action Card
struct ActionCard: View {
    let title: String
    let icon: String
    let description: String
    let gradient: Gradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(
                LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Personality Traits View
struct PersonalityTraitsView: View {
    @EnvironmentObject var viewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Personality")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Edit")
                            .font(.caption)
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            
            VStack(spacing: 16) {
                PersonalityTraitRow(
                    name: "Friendliness",
                    icon: "heart.fill",
                    value: viewModel.companionState.personality.friendliness,
                    color: .pink
                )
                
                PersonalityTraitRow(
                    name: "Helpfulness",
                    icon: "hands.sparkles.fill",
                    value: viewModel.companionState.personality.helpfulness,
                    color: .blue
                )
                
                PersonalityTraitRow(
                    name: "Humor",
                    icon: "face.smiling.fill",
                    value: viewModel.companionState.personality.humor,
                    color: .orange
                )
                
                PersonalityTraitRow(
                    name: "Empathy",
                    icon: "figure.2.arms.open",
                    value: viewModel.companionState.personality.empathy,
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Personality Trait Row
struct PersonalityTraitRow: View {
    let name: String
    let icon: String
    let value: Float
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(name)
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(value * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(color.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(color)
                            .frame(width: geometry.size.width * CGFloat(value), height: 8)
                            .animation(.spring(), value: value)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

// MARK: - Avatar Picker View
struct AvatarPickerView: View {
    @Binding var selectedModel: String
    @Environment(\.dismiss) var dismiss
    
    // Robot variants with different colors
    let avatarModels = [
        ("robot", "Orange Robot", Color.orange),
        ("robot_blue", "Blue Robot", Color.blue),
        ("robot_green", "Green Robot", Color.green),
        ("robot_purple", "Purple Robot", Color.purple),
        ("robot_pink", "Pink Robot", Color.pink),
        ("robot_orange", "Maple Robot", Color.orange)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(avatarModels, id: \.0) { model in
                        AvatarOptionCard(
                            modelName: model.0,
                            displayName: model.1,
                            color: model.2,
                            isSelected: selectedModel == model.0,
                            action: {
                                selectedModel = model.0
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Avatar Option Card
struct AvatarOptionCard: View {
    let modelName: String
    let displayName: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                // Preview container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 150)
                    
                    // Robot preview
                    VStack {
                        Image(systemName: "cpu")
                            .font(.system(size: 60))
                            .foregroundColor(color)
                        Text("🤖")
                            .font(.system(size: 40))
                    }
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 3)
                    }
                }
                
                Text(displayName)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Personality Editor View
struct PersonalityEditorView: View {
    @EnvironmentObject var viewModel: CompanionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var friendliness: Float
    @State private var helpfulness: Float
    @State private var humor: Float
    @State private var empathy: Float
    
    init() {
        // Initialize with current values
        _friendliness = State(initialValue: 0.9)
        _helpfulness = State(initialValue: 0.85)
        _humor = State(initialValue: 0.7)
        _empathy = State(initialValue: 0.95)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Adjust Personality Traits")) {
                    PersonalitySlider(
                        name: "Friendliness",
                        value: $friendliness,
                        description: "How warm and approachable Maple is"
                    )
                    
                    PersonalitySlider(
                        name: "Helpfulness",
                        value: $helpfulness,
                        description: "How eager Maple is to assist you"
                    )
                    
                    PersonalitySlider(
                        name: "Humor",
                        value: $humor,
                        description: "How playful and funny Maple can be"
                    )
                    
                    PersonalitySlider(
                        name: "Empathy",
                        value: $empathy,
                        description: "How understanding and supportive Maple is"
                    )
                }
                
                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Edit Personality")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func saveChanges() {
        viewModel.companionState.personality = CompanionState.PersonalityTraits(
            friendliness: friendliness,
            helpfulness: helpfulness,
            humor: humor,
            empathy: empathy
        )
        dismiss()
    }
}

// MARK: - Personality Slider
struct PersonalitySlider: View {
    let name: String
    @Binding var value: Float
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: 0...1)
                .accentColor(.orange)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
