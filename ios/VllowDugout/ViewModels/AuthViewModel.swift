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

    private let authService = LocalAuthService()
    private let userKey = "auth_user"
    private let onboardingKey = "has_completed_onboarding"

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        loadStoredUser()
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

    var shouldSwitchToSignIn = false

    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try authService.signUp(email: email, password: password, name: name)
            storeUser(user)
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
            let user = try authService.signIn(email: email, password: password)
            storeUser(user)
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
        UserDefaults.standard.removeObject(forKey: userKey)
        withAnimation(.easeInOut(duration: 0.4)) {
            currentUser = nil
            isAuthenticated = false
        }
    }

    private func storeUser(_ user: AuthUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    private func loadStoredUser() {
        guard let userData = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(AuthUser.self, from: userData) else {
            return
        }
        currentUser = user
        isAuthenticated = true
    }
}

nonisolated enum AuthFlowState: Equatable, Sendable {
    case onboarding
    case auth
    case main
}
