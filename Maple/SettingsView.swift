import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var companionViewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditProfile = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    @State private var showingLoginView = false
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var hapticsEnabled = true
    @State private var darkModeEnabled = false
    @State private var autoPlayVoice = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    HStack {
                        // User Avatar
                        ZStack {
                            Circle()
                                .fill(authManager.isGuestMode ? Color.gray : themeManager.currentTheme.primaryColor.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            if authManager.isGuestMode {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            } else {
                                Text(authManager.currentUser?.username.prefix(2).uppercased() ?? "U")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if authManager.isGuestMode {
                                Text("Guest User")
                                    .font(.title3)
                                    .bold()
                                Button(action: { showingLoginView.toggle() }) {
                                    HStack {
                                        Text("Sign in for full features")
                                            .font(.subheadline)
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                }
                            } else {
                                Text(authManager.currentUser?.username ?? "User")
                                    .font(.title3)
                                    .bold()
                                Text(authManager.currentUser?.email ?? "email@example.com")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Member since \(authManager.currentUser?.joinDate ?? Date(), style: .date)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if !authManager.isGuestMode {
                            Button(action: { showingEditProfile.toggle() }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Login History for Guest Users
                    if authManager.isGuestMode && authManager.hasLoginHistory {
                        Button(action: { showingLoginView.toggle() }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("Sign in as \(authManager.lastLoggedInEmail)")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                // Theme Selection
                Section(header: Text("Appearance")) {
                    HStack {
                        Label("Theme Color", systemImage: "paintbrush.fill")
                        Spacer()
                        Menu {
                            ForEach(ThemeManager.AppTheme.allCases, id: \.self) { theme in
                                Button(action: { themeManager.currentTheme = theme }) {
                                    HStack {
                                        Text(theme.rawValue)
                                        if themeManager.currentTheme == theme {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(themeManager.currentTheme.primaryColor)
                                    .frame(width: 20, height: 20)
                                Text(themeManager.currentTheme.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }
                
                // Companion Settings
                Section(header: Text("Companion Settings")) {
                    HStack {
                        Label("Companion Name", systemImage: "heart.fill")
                        Spacer()
                        Text(companionViewModel.companionName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Current Avatar", systemImage: "cube.fill")
                        Spacer()
                        Text(companionViewModel.selectedAvatar.replacingOccurrences(of: "_", with: " ").capitalized)
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: CompanionVoiceSettings()) {
                        Label("Voice Settings", systemImage: "waveform")
                    }
                    
                    NavigationLink(destination: CompanionBehaviorSettings()) {
                        Label("Behavior Settings", systemImage: "brain")
                    }
                }
                
                // App Preferences
                Section(header: Text("App Preferences")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell.fill")
                    }
                    
                    Toggle(isOn: $soundEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                    }
                    
                    Toggle(isOn: $hapticsEnabled) {
                        Label("Haptic Feedback", systemImage: "hand.tap.fill")
                    }
                    
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    
                    Toggle(isOn: $autoPlayVoice) {
                        Label("Auto-play Voice Messages", systemImage: "play.circle.fill")
                    }
                }
                
                // Data & Privacy
                Section(header: Text("Data & Privacy")) {
                    NavigationLink(destination: DataManagementView()) {
                        Label("Data Management", systemImage: "externaldrive.fill")
                    }
                    
                    Button(action: { showingPrivacy.toggle() }) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink(destination: SecuritySettingsView()) {
                        Label("Security", systemImage: "lock.fill")
                    }
                }
                
                // Support
                Section(header: Text("Support")) {
                    NavigationLink(destination: HelpCenterView()) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        Label("Send Feedback", systemImage: "envelope.fill")
                    }
                    
                    Button(action: { showingAbout.toggle() }) {
                        Label("About Maple", systemImage: "info.circle.fill")
                    }
                }
                
                // Account Actions
                Section {
                    if authManager.isGuestMode {
                        Button(action: { showingLoginView.toggle() }) {
                            Label("Sign In", systemImage: "person.badge.plus")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    } else {
                        Button(action: { showingLogoutAlert.toggle() }) {
                            Label("Logout", systemImage: "arrow.right.square.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        Button(action: { showingDeleteAccountAlert.toggle() }) {
                            Label("Delete Account", systemImage: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutMapleView()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingLoginView) {
                LoginSignupView()
                    .environmentObject(authManager)
                    .environmentObject(themeManager)
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Spacer()
                        Button(action: { showingImagePicker.toggle() }) {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 100))
                                    .foregroundColor(.orange)
                                Text("Change Photo")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Profile Information")) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: saveProfile) {
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
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                username = authManager.currentUser?.username ?? ""
                email = authManager.currentUser?.email ?? ""
            }
        }
    }
    
    private func saveProfile() {
        // Save profile changes
        dismiss()
    }
}

// MARK: - Companion Voice Settings
struct CompanionVoiceSettings: View {
    @State private var selectedVoice = "Warm"
    @State private var voiceSpeed: Double = 1.0
    @State private var voicePitch: Double = 1.0
    
    let voices = ["Warm", "Friendly", "Professional", "Playful", "Calm"]
    
    var body: some View {
        Form {
            Section(header: Text("Voice Selection")) {
                Picker("Voice Type", selection: $selectedVoice) {
                    ForEach(voices, id: \.self) { voice in
                        Text(voice).tag(voice)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: {}) {
                    Label("Preview Voice", systemImage: "play.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            Section(header: Text("Voice Adjustments")) {
                VStack(alignment: .leading) {
                    Text("Speed: \(String(format: "%.1fx", voiceSpeed))")
                        .font(.caption)
                    Slider(value: $voiceSpeed, in: 0.5...2.0, step: 0.1)
                }
                
                VStack(alignment: .leading) {
                    Text("Pitch: \(String(format: "%.1f", voicePitch))")
                        .font(.caption)
                    Slider(value: $voicePitch, in: 0.5...1.5, step: 0.1)
                }
            }
        }
        .navigationTitle("Voice Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Companion Behavior Settings
struct CompanionBehaviorSettings: View {
    @State private var responseStyle = "Balanced"
    @State private var initiateConversations = true
    @State private var learningEnabled = true
    @State private var emotionalResponses = true
    
    let responseStyles = ["Concise", "Balanced", "Detailed"]
    
    var body: some View {
        Form {
            Section(header: Text("Response Style")) {
                Picker("Style", selection: $responseStyle) {
                    ForEach(responseStyles, id: \.self) { style in
                        Text(style).tag(style)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Behavior Options")) {
                Toggle("Initiate Conversations", isOn: $initiateConversations)
                Toggle("Learning Enabled", isOn: $learningEnabled)
                Toggle("Emotional Responses", isOn: $emotionalResponses)
            }
            
            Section(header: Text("Reset Options")) {
                Button(action: {}) {
                    Text("Reset to Default Behavior")
                        .foregroundColor(.orange)
                }
                
                Button(action: {}) {
                    Text("Clear Learning History")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Behavior Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - About Maple View
struct AboutMapleView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.orange)
                    
                    Text("Maple")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Your AI Companion")
                            .font(.headline)
                        
                        Text("Maple is an advanced AI companion designed to provide helpful, friendly, and personalized assistance. With cutting-edge natural language processing and a warm personality, Maple is here to make your day better.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(icon: "brain", text: "Advanced AI Technology")
                            FeatureRow(icon: "heart.fill", text: "Personalized Interactions")
                            FeatureRow(icon: "lock.fill", text: "Privacy-First Design")
                            FeatureRow(icon: "sparkles", text: "Continuous Learning")
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Made with ❤️ by Your Team")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Link("Website", destination: URL(string: "https://example.com")!)
                            Link("Support", destination: URL(string: "https://example.com/support")!)
                            Link("Twitter", destination: URL(string: "https://twitter.com")!)
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 30)
            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    @State private var showingExportAlert = false
    @State private var showingClearChatAlert = false
    @State private var showingClearDataAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Export Data")) {
                Button(action: { showingExportAlert.toggle() }) {
                    Label("Export Chat History", systemImage: "square.and.arrow.up")
                }
                
                Button(action: { showingExportAlert.toggle() }) {
                    Label("Export User Data", systemImage: "person.text.rectangle")
                }
            }
            
            Section(header: Text("Clear Data"), footer: Text("Clearing data cannot be undone")) {
                Button(action: { showingClearChatAlert.toggle() }) {
                    Label("Clear Chat History", systemImage: "trash")
                        .foregroundColor(.red)
                }
                
                Button(action: { showingClearDataAlert.toggle() }) {
                    Label("Clear All Data", systemImage: "trash.fill")
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Storage Info")) {
                HStack {
                    Text("Chat History")
                    Spacer()
                    Text("2.3 MB")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("User Data")
                    Spacer()
                    Text("156 KB")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Cache")
                    Spacer()
                    Text("45 MB")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Total")
                        .bold()
                    Spacer()
                    Text("47.5 MB")
                        .bold()
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Export Data", isPresented: $showingExportAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Export") {
                // Handle export
            }
        } message: {
            Text("Your data will be exported in JSON format")
        }
        .alert("Clear Chat History", isPresented: $showingClearChatAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                // Handle clear
            }
        } message: {
            Text("This will permanently delete all chat messages")
        }
    }
}

// MARK: - Security Settings View
struct SecuritySettingsView: View {
    @State private var biometricEnabled = true
    @State private var autoLockEnabled = true
    @State private var autoLockTime = 5
    @State private var showingChangePassword = false
    
    let autoLockOptions = [1, 5, 15, 30]
    
    var body: some View {
        Form {
            Section(header: Text("Authentication")) {
                Toggle("Face ID / Touch ID", isOn: $biometricEnabled)
                
                Button(action: { showingChangePassword.toggle() }) {
                    Label("Change Password", systemImage: "key.fill")
                }
            }
            
            Section(header: Text("Auto-Lock")) {
                Toggle("Enable Auto-Lock", isOn: $autoLockEnabled)
                
                if autoLockEnabled {
                    Picker("Lock After", selection: $autoLockTime) {
                        ForEach(autoLockOptions, id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                }
            }
            
            Section(header: Text("Privacy")) {
                Toggle("Hide Preview in App Switcher", isOn: .constant(true))
                Toggle("Disable Screenshots", isOn: .constant(false))
            }
        }
        .navigationTitle("Security")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordView()
        }
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Password")) {
                    SecureField("Enter current password", text: $currentPassword)
                }
                
                Section(header: Text("New Password")) {
                    SecureField("Enter new password", text: $newPassword)
                    SecureField("Confirm new password", text: $confirmPassword)
                }
                
                Section {
                    Button(action: {}) {
                        Text("Update Password")
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
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Help Center View
struct HelpCenterView: View {
    let helpTopics = [
        ("Getting Started", "rocket.fill"),
        ("Using Maple", "message.fill"),
        ("Companion Features", "heart.fill"),
        ("Account & Settings", "gearshape.fill"),
        ("Troubleshooting", "wrench.and.screwdriver.fill"),
        ("FAQs", "questionmark.circle.fill")
    ]
    
    var body: some View {
        List {
            ForEach(helpTopics, id: \.0) { topic in
                NavigationLink(destination: HelpTopicDetailView(topic: topic.0)) {
                    Label(topic.0, systemImage: topic.1)
                }
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Help Topic Detail View
struct HelpTopicDetailView: View {
    let topic: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(topic)
                    .font(.largeTitle)
                    .bold()
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Add more help content here
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackType = "Bug Report"
    @State private var feedbackText = ""
    @State private var email = ""
    
    let feedbackTypes = ["Bug Report", "Feature Request", "General Feedback", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Feedback Type")) {
                    Picker("Type", selection: $feedbackType) {
                        ForEach(feedbackTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Your Feedback")) {
                    TextEditor(text: $feedbackText)
                        .frame(height: 150)
                }
                
                Section(header: Text("Contact (Optional)")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: submitFeedback) {
                        Text("Submit Feedback")
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
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func submitFeedback() {
        // Submit feedback
        dismiss()
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Last updated: January 2024")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PolicySection(
                            title: "Information We Collect",
                            content: "We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support."
                        )
                        
                        PolicySection(
                            title: "How We Use Your Information",
                            content: "We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to personalize your experience."
                        )
                        
                        PolicySection(
                            title: "Data Security",
                            content: "We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction."
                        )
                        
                        PolicySection(
                            title: "Your Rights",
                            content: "You have the right to access, update, or delete your personal information at any time through your account settings."
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Policy Section
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationManager())
            .environmentObject(CompanionViewModel())
    }
}
