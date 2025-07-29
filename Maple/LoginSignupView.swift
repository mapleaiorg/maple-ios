import SwiftUI

struct LoginSignupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [themeManager.currentTheme.primaryColor.opacity(0.3), themeManager.currentTheme.primaryColor.opacity(0.1), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Close button for guest users
                        if authManager.isGuestMode {
                            HStack {
                                Spacer()
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                        }
                        
                        // Logo and Welcome
                        VStack(spacing: 20) {
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 10)
                            
                            Text("Welcome to Maple")
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Your AI Companion Awaits")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, authManager.isGuestMode ? 20 : 60)
                        
                        // Toggle between Login and Signup
                        Picker("Mode", selection: $isLoginMode) {
                            Text("Login").tag(true)
                            Text("Sign Up").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 50)
                        
                        // Auto-fill last email if available
                        .onAppear {
                            if authManager.hasLoginHistory && isLoginMode {
                                email = authManager.lastLoggedInEmail
                            }
                        }
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            if !isLoginMode {
                                CustomTextField(
                                    placeholder: "Username",
                                    text: $username,
                                    icon: "person.fill"
                                )
                            }
                            
                            CustomTextField(
                                placeholder: "Email",
                                text: $email,
                                icon: "envelope.fill",
                                keyboardType: .emailAddress
                            )
                            
                            CustomSecureField(
                                placeholder: "Password",
                                text: $password,
                                icon: "lock.fill"
                            )
                            
                            if !isLoginMode {
                                CustomSecureField(
                                    placeholder: "Confirm Password",
                                    text: $confirmPassword,
                                    icon: "lock.fill"
                                )
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Action Button
                        Button(action: handleAuthentication) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isLoginMode ? "Login" : "Create Account")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [themeManager.currentTheme.primaryColor, themeManager.currentTheme.secondaryColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 10)
                        }
                        .padding(.horizontal, 30)
                        .disabled(isLoading)
                        
                        // Additional Options
                        VStack(spacing: 15) {
                            if isLoginMode {
                                Button(action: {}) {
                                    Text("Forgot Password?")
                                        .font(.caption)
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                }
                            }
                            
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                
                                Text("or")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 30)
                            
                            // Social Login Options
                            VStack(spacing: 12) {
                                SocialLoginButton(
                                    title: "Continue with Apple",
                                    icon: "apple.logo",
                                    color: .black,
                                    action: {}
                                )
                                
                                SocialLoginButton(
                                    title: "Continue with Google",
                                    icon: "globe",
                                    color: .blue,
                                    action: {}
                                )
                                
                                // Continue as Guest (only show if not already guest)
                                if !authManager.isGuestMode {
                                    Button(action: {
                                        authManager.continueAsGuest()
                                        dismiss()
                                    }) {
                                        HStack {
                                            Image(systemName: "person.fill.questionmark")
                                                .font(.system(size: 20))
                                            Text("Continue as Guest")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .padding(.horizontal, 30)
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                        
                        // Terms and Privacy
                        Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Authentication", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func handleAuthentication() {
        // Validation
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        if !isLoginMode {
            guard !username.isEmpty else {
                alertMessage = "Please enter a username"
                showingAlert = true
                return
            }
            
            guard password == confirmPassword else {
                alertMessage = "Passwords don't match"
                showingAlert = true
                return
            }
            
            guard password.count >= 6 else {
                alertMessage = "Password must be at least 6 characters"
                showingAlert = true
                return
            }
        }
        
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            if isLoginMode {
                if authManager.login(email: email, password: password) {
                    // Success - dismiss if shown as sheet
                    if authManager.isGuestMode {
                        dismiss()
                    }
                } else {
                    alertMessage = "Invalid email or password"
                    showingAlert = true
                }
            } else {
                if authManager.signup(email: email, username: username, password: password) {
                    // Success - dismiss if shown as sheet
                    if authManager.isGuestMode {
                        dismiss()
                    }
                } else {
                    alertMessage = "Failed to create account"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 30)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    @State private var isSecure = true
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 30)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Social Login Button
struct SocialLoginButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview
struct LoginSignupView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignupView()
            .environmentObject(AuthenticationManager())
    }
}
