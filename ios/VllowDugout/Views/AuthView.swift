import SwiftUI

struct AuthView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var confirmPassword = ""
    @State private var showForgotPassword = false
    @State private var resetEmail = ""
    @FocusState private var focusedField: AuthField?

    var body: some View {
        ZStack {
            AppTheme.darkBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 60)
                        .padding(.bottom, 40)

                    formSection
                        .padding(.horizontal, 24)

                    if !isSignUp {
                        forgotPasswordButton
                            .padding(.top, 12)
                    }

                    actionButtons
                        .padding(.horizontal, 24)
                        .padding(.top, 28)

                    toggleSection
                        .padding(.top, 24)

                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .alert("Error", isPresented: $authViewModel.showError) {
            if authViewModel.shouldSwitchToSignIn {
                Button("Sign In Instead") {
                    authViewModel.showError = false
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isSignUp = false
                    }
                    authViewModel.shouldSwitchToSignIn = false
                }
                Button("Cancel", role: .cancel) {
                    authViewModel.showError = false
                    authViewModel.shouldSwitchToSignIn = false
                }
            } else {
                Button("OK") { authViewModel.showError = false }
            }
        } message: {
            Text(authViewModel.errorMessage ?? "Something went wrong")
        }
        .alert("Password Reset", isPresented: $authViewModel.showResetSent) {
            Button("OK") {}
        } message: {
            Text("A password reset link has been sent to your email.")
        }
        .sheet(isPresented: $showForgotPassword) {
            forgotPasswordSheet
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.neonGreenDim)
                    .frame(width: 90, height: 90)

                Circle()
                    .fill(AppTheme.cardSurface)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.neonGreen.opacity(0.4), lineWidth: 1)
                    )

                Image(systemName: "cricket.ball.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.neonGreen)
            }

            VStack(spacing: 6) {
                Text("Vllow Dugout")
                    .font(.system(size: 28, weight: .black))
                    .tracking(-0.3)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(isSignUp ? "Create your account" : "Welcome back, champ")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            if isSignUp {
                AuthTextField(
                    icon: "person.fill",
                    placeholder: "Full Name",
                    text: $name,
                    focusedField: $focusedField,
                    field: .name
                )
                .textContentType(.name)
                .textInputAutocapitalization(.words)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            AuthTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                focusedField: $focusedField,
                field: .email
            )
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)

            AuthTextField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                isSecure: true,
                focusedField: $focusedField,
                field: .password
            )
            .textContentType(isSignUp ? .newPassword : .password)

            if isSignUp {
                AuthTextField(
                    icon: "lock.shield.fill",
                    placeholder: "Confirm Password",
                    text: $confirmPassword,
                    isSecure: true,
                    focusedField: $focusedField,
                    field: .confirmPassword
                )
                .textContentType(.newPassword)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSignUp)
    }

    private var forgotPasswordButton: some View {
        Button {
            resetEmail = email
            showForgotPassword = true
        } label: {
            Text("Forgot Password?")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.neonGreen.opacity(0.8))
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button {
                focusedField = nil
                Task { await performAuth() }
            } label: {
                HStack(spacing: 10) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(Color(red: 0.07, green: 0.07, blue: 0.06))
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(size: 17, weight: .bold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.06))
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(isFormValid ? AppTheme.neonGreen : AppTheme.neonGreen.opacity(0.3))
                .clipShape(.rect(cornerRadius: 29))
            }
            .disabled(!isFormValid || authViewModel.isLoading)
            .sensoryFeedback(.impact(weight: .medium), trigger: authViewModel.isAuthenticated)
        }
    }

    private var toggleSection: some View {
        HStack(spacing: 4) {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isSignUp.toggle()
                    clearForm()
                }
            } label: {
                Text(isSignUp ? "Sign In" : "Sign Up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.neonGreen)
            }
        }
    }

    private var forgotPasswordSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.neonGreen)
                        .padding(.bottom, 8)

                    Text("Reset Password")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AuthTextField(
                    icon: "envelope.fill",
                    placeholder: "Email",
                    text: $resetEmail,
                    focusedField: $focusedField,
                    field: .email
                )
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(.horizontal, 24)

                Button {
                    Task {
                        await authViewModel.sendPasswordReset(email: resetEmail)
                        showForgotPassword = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(Color(red: 0.07, green: 0.07, blue: 0.06))
                        } else {
                            Text("Send Reset Link")
                                .font(.system(size: 17, weight: .bold))
                        }
                    }
                    .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.06))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(!resetEmail.isEmpty ? AppTheme.neonGreen : AppTheme.neonGreen.opacity(0.3))
                    .clipShape(.rect(cornerRadius: 27))
                }
                .disabled(resetEmail.isEmpty || authViewModel.isLoading)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 32)
            .background(AppTheme.darkBg)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showForgotPassword = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && !confirmPassword.isEmpty && password == confirmPassword && password.count >= 6
        }
        return !email.isEmpty && !password.isEmpty
    }

    private func performAuth() async {
        if isSignUp {
            await authViewModel.signUp(email: email, password: password, name: name)
        } else {
            await authViewModel.signIn(email: email, password: password)
        }
    }

    private func clearForm() {
        email = ""
        password = ""
        name = ""
        confirmPassword = ""
        authViewModel.errorMessage = nil
    }
}

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var focusedField: FocusState<AuthField?>.Binding
    let field: AuthField
    @State private var showPassword = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(focusedField.wrappedValue == field ? AppTheme.neonGreen : AppTheme.textTertiary)
                .frame(width: 20)

            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .focused(focusedField, equals: field)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .focused(focusedField, equals: field)
            }

            if isSecure {
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    focusedField.wrappedValue == field ? AppTheme.neonGreen.opacity(0.5) : AppTheme.border,
                    lineWidth: focusedField.wrappedValue == field ? 1.5 : 0.5
                )
        )
        .animation(.easeInOut(duration: 0.2), value: focusedField.wrappedValue)
    }
}

nonisolated enum AuthField: Hashable, Sendable {
    case name
    case email
    case password
    case confirmPassword
}
