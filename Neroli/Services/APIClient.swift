import Foundation

actor APIClient {
    static let shared = APIClient()

    #if DEBUG
    private let baseURL = "http://localhost:3000/api"
    #else
    private let baseURL = "https://neroli-api.vercel.app/api"
    #endif

    private var accessToken: String?
    private var refreshToken: String?

    func setTokens(access: String, refresh: String) {
        self.accessToken = access
        self.refreshToken = refresh
        // Save refresh token to Keychain
        KeychainHelper.save(key: "refreshToken", value: refresh)
    }

    func clearTokens() {
        self.accessToken = nil
        self.refreshToken = nil
        KeychainHelper.delete(key: "refreshToken")
    }

    // MARK: - Request Builder

    private func makeRequest(
        path: String,
        method: String = "GET",
        body: Encodable? = nil,
        authenticated: Bool = true
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    // MARK: - JSON Requests

    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Encodable? = nil,
        authenticated: Bool = true
    ) async throws -> T {
        let request = try makeRequest(path: path, method: method, body: body, authenticated: authenticated)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401, authenticated {
            // Try token refresh
            if try await attemptTokenRefresh() {
                return try await self.request(path: path, method: method, body: body, authenticated: authenticated)
            }
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - SSE Streaming

    func streamChat(
        conversationId: String?,
        message: String,
        onText: @escaping @Sendable (String) -> Void,
        onConversationId: @escaping @Sendable (String) -> Void
    ) async throws {
        struct ChatBody: Encodable {
            let conversationId: String?
            let message: String
        }

        let request = try makeRequest(
            path: "/chat",
            method: "POST",
            body: ChatBody(conversationId: conversationId, message: message)
        )

        let (bytes, response) = try await URLSession.shared.bytes(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            if let convId = httpResponse.value(forHTTPHeaderField: "X-Conversation-Id") {
                onConversationId(convId)
            }
        }

        for try await line in bytes.lines {
            // Vercel AI SDK data stream format: "0:text"
            if line.hasPrefix("0:") {
                let text = String(line.dropFirst(2))
                // Remove surrounding quotes if present
                let cleaned = text.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                onText(cleaned)
            }
        }
    }

    // MARK: - Token Refresh

    private func attemptTokenRefresh() async throws -> Bool {
        guard let refresh = refreshToken else { return false }

        struct RefreshBody: Encodable { let refreshToken: String }
        let request = try makeRequest(
            path: "/auth/refresh",
            method: "POST",
            body: RefreshBody(refreshToken: refresh),
            authenticated: false
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return false
        }

        let tokens = try JSONDecoder().decode(AuthTokens.self, from: data)
        setTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
        return true
    }
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response"
        case .unauthorized: return "Please sign in again"
        case .httpError(let code): return "Server error (\(code))"
        }
    }
}
