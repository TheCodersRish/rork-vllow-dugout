import SwiftUI

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

    private let authService = StytchAuthService()
    private let onboardingKey = "has_completed_onboarding"

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        Task { await restoreSession() }
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
        Task {
            do {
                try await authService.signOut()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            withAnimation(.easeInOut(duration: 0.4)) {
                currentUser = nil
                isAuthenticated = false
            }
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

    private func restoreSession() async {
        if let user = await authService.getCurrentUser() {
            currentUser = user
            withAnimation(.easeInOut(duration: 0.4)) {
                isAuthenticated = true
            }
        }
    }
}

nonisolated enum AuthFlowState: Equatable, Sendable {
    case onboarding
    case auth
    case main
}
