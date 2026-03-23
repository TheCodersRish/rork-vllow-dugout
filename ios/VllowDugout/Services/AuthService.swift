import Foundation
import CryptoKit

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

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Invalid email or password"
        case .emailAlreadyExists: "An account with this email already exists"
        case .weakPassword: "Password must be at least 6 characters"
        case .userNotFound: "No account found with this email"
        }
    }
}

nonisolated struct StoredAccount: Codable, Sendable {
    let id: String
    let email: String
    let name: String?
    let passwordHash: String
    let createdAt: String
}

class LocalAuthService {
    private let accountsKey = "stored_accounts"
    private let schemaVersionKey = "auth_schema_version"
    private let currentSchemaVersion = 2

    init() {
        let storedVersion = UserDefaults.standard.integer(forKey: schemaVersionKey)
        if storedVersion < currentSchemaVersion {
            UserDefaults.standard.removeObject(forKey: accountsKey)
            UserDefaults.standard.set(currentSchemaVersion, forKey: schemaVersionKey)
        }
    }

    func signUp(email: String, password: String, name: String) throws -> AuthUser {
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        var accounts = loadAccounts()

        if accounts.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            throw AuthError.emailAlreadyExists
        }

        let hash = hashPassword(password)
        let now = ISO8601DateFormatter().string(from: Date())
        let account = StoredAccount(
            id: UUID().uuidString,
            email: email.lowercased(),
            name: name,
            passwordHash: hash,
            createdAt: now
        )

        accounts.append(account)
        saveAccounts(accounts)

        return AuthUser(id: account.id, email: account.email, name: account.name, createdAt: account.createdAt)
    }

    func signIn(email: String, password: String) throws -> AuthUser {
        let accounts = loadAccounts()
        let hash = hashPassword(password)

        guard let account = accounts.first(where: {
            $0.email.lowercased() == email.lowercased() && $0.passwordHash == hash
        }) else {
            throw AuthError.invalidCredentials
        }

        return AuthUser(id: account.id, email: account.email, name: account.name, createdAt: account.createdAt)
    }

    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func loadAccounts() -> [StoredAccount] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let accounts = try? JSONDecoder().decode([StoredAccount].self, from: data) else {
            return []
        }
        return accounts
    }

    private func saveAccounts(_ accounts: [StoredAccount]) {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: accountsKey)
        }
    }
}
