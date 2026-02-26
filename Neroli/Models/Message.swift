import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let conversationId: String
    let role: Role
    let content: String
    let createdAt: Date

    enum Role: String, Codable {
        case user
        case assistant
    }
}

struct Conversation: Identifiable, Codable {
    let id: String
    let title: String?
    let summary: String?
    let createdAt: Date
    let updatedAt: Date
    var messages: [ChatMessage]?
}
