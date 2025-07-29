import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var companionViewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 1 // Default to Companion tab
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ChatView()
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                    .tag(0)
                
                CompanionView()
                    .tabItem {
                        Label("Companion", systemImage: "heart.fill")
                    }
                    .tag(1)
                
                InsightsView()
                    .tabItem {
                        Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(2)
            }
            .accentColor(themeManager.currentTheme.primaryColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings.toggle() }) {
                        HStack(spacing: 8) {
                            Text(authManager.displayName)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundColor(authManager.isGuestMode ? .gray : themeManager.currentTheme.primaryColor)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(authManager)
                .environmentObject(companionViewModel)
                .environmentObject(themeManager)
        }
    }
}

// MARK: - Insights View
struct InsightsView: View {
    @EnvironmentObject var companionViewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Summary Card
                    VStack(alignment: .leading, spacing: 16) {
                        Label("This Week", systemImage: "calendar")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        HStack(spacing: 20) {
                            InsightCard(
                                title: "Chats",
                                value: "47",
                                icon: "message.fill",
                                color: .blue
                            )
                            
                            InsightCard(
                                title: "Energy",
                                value: "+15%",
                                icon: "bolt.fill",
                                color: .yellow
                            )
                            
                            InsightCard(
                                title: "Mood",
                                value: "Happy",
                                icon: "face.smiling.fill",
                                color: .green
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    
                    // Interaction History
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Recent Activities", systemImage: "clock.fill")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        ForEach(0..<5) { index in
                            HStack {
                                Circle()
                                    .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: ["gamecontroller", "leaf", "bubble.left", "moon", "heart"].randomElement()!)
                                            .foregroundColor(themeManager.currentTheme.primaryColor)
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text(["Played together", "Fed Maple", "Had a chat", "Rest time", "Bonding moment"].randomElement()!)
                                        .font(.subheadline)
                                    Text("\(Int.random(in: 1...60)) minutes ago")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                }
                .padding()
            }
            .navigationTitle("Insights")
            .background(Color(.systemGray6))
        }
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Shared Models
struct Message: Identifiable, Codable {
    var id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let messageType: MessageType
    var attachmentURL: String?
    
    enum MessageType: Codable {
        case text
        case image
        case voice
        case companionAction
    }
}

struct CompanionState: Codable {
    var mood: CompanionMood
    var energy: Int // 0-100
    var lastInteraction: Date
    var personality: PersonalityTraits
    
    enum CompanionMood: String, Codable {
        case happy = "happy"
        case neutral = "neutral"
        case thoughtful = "thoughtful"
        case excited = "excited"
        case sleepy = "sleepy"
    }
    
    struct PersonalityTraits: Codable {
        var friendliness: Float // 0.0 - 1.0
        var helpfulness: Float
        var humor: Float
        var empathy: Float
    }
}

struct UserProfile: Codable {
    var name: String
    var preferences: UserPreferences
    var companionCustomization: CompanionCustomization
    var statistics: UserStatistics
    
    struct UserPreferences: Codable {
        var notificationsEnabled: Bool
        var darkModeEnabled: Bool
        var preferredLanguage: String
        var aiPersonality: String
    }
    
    struct CompanionCustomization: Codable {
        var selectedAvatar: String // File name in Resources
        var selectedVoice: String
        var companionName: String
        var preferredMood: String
    }
    
    struct UserStatistics: Codable {
        var totalMessages: Int
        var totalInteractions: Int
        var joinDate: Date
        var streakDays: Int
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationManager())
            .environmentObject(ChatViewModel())
            .environmentObject(CompanionViewModel())
    }
}
