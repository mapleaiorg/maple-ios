import SwiftUI

@main
struct MapleApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var companionViewModel = CompanionViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var showingSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(chatViewModel)
                    .environmentObject(companionViewModel)
                    .environmentObject(themeManager)
                    .accentColor(themeManager.currentTheme.primaryColor)
                
                if showingSplash {
                    SplashScreen()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Hide splash screen after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showingSplash = false
                    }
                }
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var animationAmount = 0.8
    @State private var textOpacity = 0.0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.8, green: 0.2, blue: 0.2),
                    Color(red: 0.9, green: 0.3, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                    .scaleEffect(animationAmount)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Title
                VStack(spacing: 8) {
                    Text("MapleAI")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Your AI Companion")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(textOpacity)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 40)
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationAmount = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .mapleRed
    
    enum AppTheme: String, CaseIterable {
        case mapleRed = "Maple Red"
        case orange = "Orange"
        case blue = "Ocean Blue"
        case purple = "Royal Purple"
        case green = "Forest Green"
        
        var primaryColor: Color {
            switch self {
            case .mapleRed: return Color(red: 0.8, green: 0.2, blue: 0.2) // Canada Maple Red
            case .orange: return .orange
            case .blue: return .blue
            case .purple: return .purple
            case .green: return .green
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .mapleRed: return Color(red: 0.9, green: 0.3, blue: 0.3)
            case .orange: return .orange.opacity(0.8)
            case .blue: return .blue.opacity(0.8)
            case .purple: return .purple.opacity(0.8)
            case .green: return .green.opacity(0.8)
            }
        }
    }
}

// MARK: - Authentication Manager
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isGuestMode = true
    @AppStorage("lastLoggedInEmail") var lastLoggedInEmail = ""
    @AppStorage("hasLoginHistory") var hasLoginHistory = false
    
    var displayName: String {
        if isGuestMode {
            return "Guest"
        } else {
            return currentUser?.username ?? "User"
        }
    }
    
    struct User: Codable {
        let id: UUID
        var email: String
        var username: String
        var avatarName: String
        var joinDate: Date
        var profileImage: String?
    }
    
    init() {
        // Start in guest mode by default
        isGuestMode = true
        isAuthenticated = false
    }
    
    func continueAsGuest() {
        isGuestMode = true
        isAuthenticated = false
    }
    
    func login(email: String, password: String) -> Bool {
        // Simulate authentication - replace with actual auth logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAuthenticated = true
            self?.isGuestMode = false
            self?.currentUser = User(
                id: UUID(),
                email: email,
                username: email.components(separatedBy: "@").first ?? "User",
                avatarName: "maple_avatar_1",
                joinDate: Date()
            )
            self?.lastLoggedInEmail = email
            self?.hasLoginHistory = true
        }
        return true
    }
    
    func signup(email: String, username: String, password: String) -> Bool {
        // Simulate signup - replace with actual auth logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAuthenticated = true
            self?.isGuestMode = false
            self?.currentUser = User(
                id: UUID(),
                email: email,
                username: username,
                avatarName: "maple_avatar_1",
                joinDate: Date()
            )
            self?.lastLoggedInEmail = email
            self?.hasLoginHistory = true
        }
        return true
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        // Don't change guest mode on logout - user can still use guest features
    }
}
