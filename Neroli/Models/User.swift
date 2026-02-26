import Foundation

struct User: Codable {
    let id: String
    let email: String?
    let displayName: String?
    let avatarUrl: String?
    let createdAt: Date?
}

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User?
    let isNewUser: Bool?
}
