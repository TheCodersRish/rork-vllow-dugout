import CFNetwork
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
    case invalidEmail
    case networkError
    case operationNotAllowed
    case invalidAPIKey
    case appNotAuthorized
    case tooManyRequests
    case keychainError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Invalid email or password"
        case .emailAlreadyExists: "An account with this email already exists"
        case .weakPassword: "Password must be at least 6 characters"
        case .userNotFound: "No account found with this email"
        case .invalidEmail: "That email address doesn't look valid"
        case .networkError:
            "Can't reach Firebase. Check internet, disable VPN if it blocks Google, and try again."
        case .operationNotAllowed:
            "Email/password sign-in is turned off for this app. In Firebase Console: Authentication → Sign-in method → enable Email/Password."
        case .invalidAPIKey:
            "Invalid API key or iOS app setup. In Google Cloud Console, ensure this iOS app's API key allows Identity Toolkit, or re-download GoogleService-Info.plist."
        case .appNotAuthorized:
            "This app isn't authorized for Firebase Auth. Confirm the iOS bundle ID in Firebase matches the Xcode target (com.vllowsports.dugout)."
        case .tooManyRequests:
            "Too many attempts. Wait a minute and try again."
        case .keychainError:
            "Keychain access failed. On Simulator, try Reset Content and Settings; on device, ensure Keychain Sharing isn’t misconfigured."
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
        } catch {
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
        } catch {
            throw mapFirebaseError(error)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
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

    private func mapFirebaseError(_ error: Error) -> AuthError {
        var current: NSError? = error as NSError
        var depth = 0
        while let ns = current, depth < 8 {
            depth += 1

            if ns.domain == NSURLErrorDomain || ns.domain == (kCFErrorDomainCFNetwork as String) {
                return .networkError
            }

            if ns.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .emailAlreadyInUse:
                    return .emailAlreadyExists
                case .wrongPassword, .invalidCredential:
                    return .invalidCredentials
                case .userNotFound:
                    return .userNotFound
                case .weakPassword:
                    return .weakPassword
                case .invalidEmail:
                    return .invalidEmail
                case .networkError, .webNetworkRequestFailed:
                    return .networkError
                case .operationNotAllowed:
                    return .operationNotAllowed
                case .invalidAPIKey:
                    return .invalidAPIKey
                case .appNotAuthorized:
                    return .appNotAuthorized
                case .missingIosBundleID:
                    return .appNotAuthorized
                case .tooManyRequests:
                    return .tooManyRequests
                case .keychainError:
                    return .keychainError
                case .internalError, .webInternalError:
                    if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError {
                        current = underlying
                        continue
                    }
                    return .unknown(ns.localizedDescription)
                default:
                    return .unknown(ns.localizedDescription)
                }
            }

            if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError {
                current = underlying
                continue
            }

            return .unknown(ns.localizedDescription)
        }

        return .unknown((error as NSError).localizedDescription)
    }
}
