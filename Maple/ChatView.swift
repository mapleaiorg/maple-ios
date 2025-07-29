import SwiftUI
import Combine

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @EnvironmentObject var companionViewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingImagePicker = false
    @State private var showingVoiceRecorder = false
    @State private var isRecording = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Companion Status Bar
                CompanionStatusBar()
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isTyping {
                                TypingIndicator()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                // Input Bar
                ChatInputBar(
                    text: $viewModel.currentInput,
                    showingImagePicker: $showingImagePicker,
                    showingVoiceRecorder: $showingVoiceRecorder,
                    isRecording: $isRecording,
                    onSend: viewModel.sendMessage
                )
            }
            .navigationTitle("Maple")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showCompanionInfo.toggle() }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showCompanionInfo) {
            CompanionInfoSheet()
        }
    }
}

// MARK: - Chat View Model
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentInput = ""
    @Published var isTyping = false
    @Published var showCompanionInfo = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add welcome message
        messages.append(Message(
            content: "Hi! I'm Maple, your AI companion. How can I help you today? 🍁",
            isUser: false,
            timestamp: Date(),
            messageType: .text
        ))
    }
    
    func sendMessage() {
        guard !currentInput.isEmpty else { return }
        
        let userMessage = Message(
            content: currentInput,
            isUser: true,
            timestamp: Date(),
            messageType: .text
        )
        messages.append(userMessage)
        
        let input = currentInput
        currentInput = ""
        
        // Simulate AI response with typing delay
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.0...2.5)) { [weak self] in
            self?.isTyping = false
            let response = self?.generateResponse(for: input) ?? "I'm here to help!"
            let aiMessage = Message(
                content: response,
                isUser: false,
                timestamp: Date(),
                messageType: .text
            )
            self?.messages.append(aiMessage)
        }
    }
    
    private func generateResponse(for input: String) -> String {
        let lowercased = input.lowercased()
        
        // Maple-themed responses
        if lowercased.contains("hello") || lowercased.contains("hi") {
            return ["Hey there! 🍁 Ready for another great conversation?",
                    "Hello! It's wonderful to see you again! How's your day going?",
                    "Hi friend! What adventures shall we embark on today? 🌟"].randomElement()!
        } else if lowercased.contains("how are you") {
            return "I'm feeling energetic and ready to help! Like a crisp autumn day 🍂 What's on your mind?"
        } else if lowercased.contains("help") {
            return "I'm here to assist you with anything you need! Whether it's answering questions, having a chat, or just being a friendly companion. What can I do for you? 💫"
        } else if lowercased.contains("maple") {
            return "You called? 🍁 That's me! I chose the name Maple because it represents growth, beauty, and the changing seasons - just like our conversations!"
        } else if lowercased.contains("companion") {
            return "As your AI companion, I'm here to chat, help, and make your day a little brighter! You can customize my appearance and personality in the Companion tab. 🎨"
        } else {
            let responses = [
                "That's fascinating! Tell me more about \(input). I love learning new things! 🤔",
                "I appreciate you sharing that with me. Let's explore this topic together! 🌟",
                "Interesting perspective! Here's what I think about that... 💭",
                "Great question! Let me think about this for a moment... 🍁"
            ]
            return responses.randomElement()!
        }
    }
}

// MARK: - Companion Status Bar
struct CompanionStatusBar: View {
    @EnvironmentObject var companionViewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Companion Avatar
            Image(systemName: "leaf.fill")
                .font(.system(size: 24))
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .background(
                    Circle()
                        .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Maple")
                    .font(.headline)
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text(companionViewModel.currentMoodText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Energy Level
            VStack(alignment: .trailing, spacing: 2) {
                Text("Energy")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ProgressView(value: Double(companionViewModel.companionState.energy), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: themeManager.currentTheme.primaryColor))
                    .frame(width: 80)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if !message.isUser {
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? themeManager.currentTheme.primaryColor : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationAmount = 1.0
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(themeManager.currentTheme.primaryColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationAmount)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationAmount
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(20)
        .onAppear {
            animationAmount = 0.5
        }
    }
}

// MARK: - Chat Input Bar
struct ChatInputBar: View {
    @Binding var text: String
    @Binding var showingImagePicker: Bool
    @Binding var showingVoiceRecorder: Bool
    @Binding var isRecording: Bool
    let onSend: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { showingImagePicker.toggle() }) {
                Image(systemName: "photo")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .font(.system(size: 22))
            }
            
            Button(action: {
                isRecording.toggle()
                showingVoiceRecorder.toggle()
            }) {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .foregroundColor(isRecording ? .red : themeManager.currentTheme.primaryColor)
                    .font(.system(size: 22))
            }
            
            HStack {
                TextField("Message Maple...", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .font(.system(size: 28))
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(25)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Companion Info Sheet
struct CompanionInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var companionViewModel: CompanionViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar Display
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding()
                    
                    Text("Maple")
                        .font(.title)
                        .bold()
                    
                    // Stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        InfoCard(title: "Mood", value: companionViewModel.currentMoodText, icon: "face.smiling")
                        InfoCard(title: "Energy", value: "\(companionViewModel.companionState.energy)%", icon: "bolt.fill")
                        InfoCard(title: "Personality", value: "Friendly", icon: "sparkles")
                        InfoCard(title: "Voice", value: "Warm", icon: "speaker.wave.2.fill")
                    }
                    .padding(.horizontal)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About Maple")
                            .font(.headline)
                        
                        Text("Maple is your personal AI companion, designed to be helpful, friendly, and supportive. With a warm personality and endless patience, Maple is here to assist you with questions, have meaningful conversations, or simply be a friendly presence in your day.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("About Your Companion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            Text(value)
                .font(.headline)
            
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
