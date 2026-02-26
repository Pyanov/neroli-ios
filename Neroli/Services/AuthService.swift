import SwiftUI
import AuthenticationServices

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?

    init() {
        // Check for stored refresh token on launch
        if KeychainHelper.load(key: "refreshToken") != nil {
            Task { await restoreSession() }
        }
    }

    // MARK: - Email Auth

    func register(email: String, password: String, displayName: String?) async {
        isLoading = true
        error = nil

        struct RegisterBody: Encodable {
            let email: String
            let password: String
            let displayName: String?
        }

        do {
            let tokens: AuthTokens = try await APIClient.shared.request(
                path: "/auth/register",
                method: "POST",
                body: RegisterBody(email: email, password: password, displayName: displayName),
                authenticated: false
            )
            await APIClient.shared.setTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
            currentUser = tokens.user
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        struct LoginBody: Encodable {
            let email: String
            let password: String
        }

        do {
            let tokens: AuthTokens = try await APIClient.shared.request(
                path: "/auth/login",
                method: "POST",
                body: LoginBody(email: email, password: password),
                authenticated: false
            )
            await APIClient.shared.setTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
            currentUser = tokens.user
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Apple Sign-In

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        error = nil

        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                error = "Failed to get Apple credentials"
                isLoading = false
                return
            }

            let displayName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")

            struct AppleBody: Encodable {
                let identityToken: String
                let displayName: String?
            }

            do {
                let tokens: AuthTokens = try await APIClient.shared.request(
                    path: "/auth/apple",
                    method: "POST",
                    body: AppleBody(identityToken: identityToken, displayName: displayName.isEmpty ? nil : displayName),
                    authenticated: false
                )
                await APIClient.shared.setTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
                currentUser = tokens.user
                isAuthenticated = true
            } catch {
                self.error = error.localizedDescription
            }

        case .failure(let err):
            error = err.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Session

    func signOut() async {
        await APIClient.shared.clearTokens()
        currentUser = nil
        isAuthenticated = false
    }

    private func restoreSession() async {
        isLoading = true
        do {
            let user: User = try await APIClient.shared.request(path: "/user/profile")
            currentUser = user
            isAuthenticated = true
        } catch {
            await APIClient.shared.clearTokens()
        }
        isLoading = false
    }
}
