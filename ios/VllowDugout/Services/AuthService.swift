import Foundation
import FirebaseAuth

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
        case .weakPassword: "Password must be at least 6 characters"
        case .userNotFound: "No account found with this email"
        case .networkError: "Network error. Please check your connection."
        case .unknown(let msg): msg
        }
    }
}

class FirebaseAuthService {
    func signUp(email: String, password: String, name: String) async throws -> AuthUser {
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()

            return AuthUser(
                id: result.user.uid,
                email: result.user.email ?? email,
                name: name,
                createdAt: ISO8601DateFormatter().string(from: result.user.metadata.creationDate ?? Date())
            )
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return AuthUser(
                id: result.user.uid,
                email: result.user.email ?? email,
                name: result.user.displayName,
                createdAt: result.user.metadata.creationDate.map { ISO8601DateFormatter().string(from: $0) }
            )
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func getCurrentUser() -> AuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AuthUser(
            id: user.uid,
            email: user.email ?? "",
            name: user.displayName,
            createdAt: user.metadata.creationDate.map { ISO8601DateFormatter().string(from: $0) }
        )
    }

    func addAuthStateListener(_ handler: @escaping (AuthUser?) -> Void) -> NSObjectProtocol {
        return Auth.auth().addStateDidChangeListener { _, firebaseUser in
            if let user = firebaseUser {
                let authUser = AuthUser(
                    id: user.uid,
                    email: user.email ?? "",
                    name: user.displayName,
                    createdAt: user.metadata.creationDate.map { ISO8601DateFormatter().string(from: $0) }
                )
                handler(authUser)
            } else {
                handler(nil)
            }
        }
    }

    private func mapFirebaseError(_ error: NSError) -> AuthError {
        guard error.domain == AuthErrorDomain else {
            return .unknown(error.localizedDescription)
        }
        let code = AuthErrorCode(rawValue: error.code)
        switch code {
        case .emailAlreadyInUse:
            return .emailAlreadyExists
        case .wrongPassword, .invalidCredential:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
