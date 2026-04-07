import SwiftUI
import FirebaseAuth

@Observable
@MainActor
class AuthViewModel {
    var isAuthenticated = false
    var hasCompletedOnboarding = false
    var currentUser: AuthUser?
    var isLoading = false
    var errorMessage: String?
    var showError = false
    var shouldSwitchToSignIn = false
    var showResetSent = false

    private let authService = FirebaseAuthService()
    private let onboardingKey = "has_completed_onboarding"
    private var authListener: NSObjectProtocol?

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        setupAuthListener()
    }

    var authState: AuthFlowState {
        if !hasCompletedOnboarding {
            return .onboarding
        } else if !isAuthenticated {
            return .auth
        } else {
            return .main
        }
    }

    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await authService.signUp(email: email, password: password, name: name)
            withAnimation(.easeInOut(duration: 0.4)) {
                currentUser = user
                isAuthenticated = true
            }
        } catch AuthError.emailAlreadyExists {
            shouldSwitchToSignIn = true
            errorMessage = "Account already exists — sign in instead"
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await authService.signIn(email: email, password: password)
            withAnimation(.easeInOut(duration: 0.4)) {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await authService.sendPasswordReset(email: email)
            showResetSent = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func setupAuthListener() {
        if let user = authService.getCurrentUser() {
            currentUser = user
            isAuthenticated = true
        }

        authListener = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                guard let self else { return }
                if let user {
                    self.currentUser = user
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.isAuthenticated = true
                    }
                } else {
                    self.currentUser = nil
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.isAuthenticated = false
                    }
                }
            }
        }
    }
}

nonisolated enum AuthFlowState: Equatable, Sendable {
    case onboarding
    case auth
    case main
}
