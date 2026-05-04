import Foundation
import StytchCore

nonisolated struct AuthUser: Codable, Sendable {
    let id: String
    let email: String
    let name: String?
    let createdAt: String?
}

nonisolated enum AuthError: Error, LocalizedError, Sendable {
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case userNotFound
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Invalid email or password"
        case .emailAlreadyExists: "An account with this email already exists"
        case .weakPassword: "Password must be at least 8 characters and strong"
        case .userNotFound: "No account found with this email"
        case .networkError: "Network error. Please check your connection."
        case .unknown(let msg): msg
        }
    }
}

@MainActor
final class StytchAuthService {
    private let displayNameKey = "vllow_user_display_name"
    private var isConfigured = false

    init() {
        configureIfNeeded()
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }
        let token = Config.EXPO_PUBLIC_STYTCH_PUBLIC_TOKEN
        guard !token.isEmpty else { return }
        StytchClient.configure(configuration: StytchClientConfiguration(publicToken: token))
        isConfigured = true
    }

    func signUp(email: String, password: String, name: String) async throws -> AuthUser {
        configureIfNeeded()
        guard password.count >= 8 else { throw AuthError.weakPassword }

        do {
            let response = try await StytchClient.passwords.create(
                parameters: StytchClient.Passwords.PasswordParameters(email: email, password: password)
            )
            let userId = response.wrapped.user.id.rawValue
            saveDisplayName(name, forUserID: userId)
            return AuthUser(
                id: userId,
                email: email,
                name: name,
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
        } catch {
            throw mapStytchError(error)
        }
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        configureIfNeeded()
        do {
            let response = try await StytchClient.passwords.authenticate(
                parameters: StytchClient.Passwords.PasswordParameters(email: email, password: password)
            )
            let userId = response.wrapped.user.id.rawValue
            let storedName = loadDisplayName(forUserID: userId)
            return AuthUser(
                id: userId,
                email: email,
                name: storedName,
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
        } catch {
            throw mapStytchError(error)
        }
    }

    func signOut() async throws {
        configureIfNeeded()
        do {
            _ = try await StytchClient.sessions.revoke()
        } catch {
            throw mapStytchError(error)
        }
    }

    func sendPasswordReset(email: String) async throws {
        configureIfNeeded()
        do {
            _ = try await StytchClient.passwords.resetByEmailStart(
                parameters: StytchClient.Passwords.ResetByEmailStartParameters(email: email)
            )
        } catch {
            throw mapStytchError(error)
        }
    }

    func getCurrentUser() async -> AuthUser? {
        configureIfNeeded()
        guard let user = StytchClient.user.getSync() else { return nil }
        let id = user.id.rawValue
        let email = user.emails.first?.email ?? ""
        return AuthUser(
            id: id,
            email: email,
            name: loadDisplayName(forUserID: id),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    private func saveDisplayName(_ name: String, forUserID id: String) {
        var dict = UserDefaults.standard.dictionary(forKey: displayNameKey) as? [String: String] ?? [:]
        dict[id] = name
        UserDefaults.standard.set(dict, forKey: displayNameKey)
    }

    private func loadDisplayName(forUserID id: String) -> String? {
        let dict = UserDefaults.standard.dictionary(forKey: displayNameKey) as? [String: String] ?? [:]
        return dict[id]
    }

    private func mapStytchError(_ error: Error) -> AuthError {
        let message = error.localizedDescription.lowercased()
        if message.contains("duplicate") || message.contains("already") {
            return .emailAlreadyExists
        }
        if message.contains("weak") || message.contains("strength") {
            return .weakPassword
        }
        if message.contains("not found") || message.contains("email_not_found") {
            return .userNotFound
        }
        if message.contains("invalid") || message.contains("incorrect") || message.contains("unauthorized") {
            return .invalidCredentials
        }
        if message.contains("network") || message.contains("offline") {
            return .networkError
        }
        return .unknown(error.localizedDescription)
    }
}
