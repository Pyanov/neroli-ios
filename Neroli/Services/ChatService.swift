import SwiftUI

@MainActor
class ChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var conversations: [Conversation] = []
    @Published var currentConversationId: String?
    @Published var isStreaming = false
    @Published var streamingText = ""

    // MARK: - Conversations

    func loadConversations() async {
        do {
            conversations = try await APIClient.shared.request(path: "/conversations")
        } catch {
            print("Failed to load conversations:", error)
        }
    }

    func loadConversation(_ id: String) async {
        do {
            let conv: Conversation = try await APIClient.shared.request(path: "/conversations/\(id)")
            currentConversationId = id
            messages = conv.messages ?? []
        } catch {
            print("Failed to load conversation:", error)
        }
    }

    func deleteConversation(_ id: String) async {
        struct Empty: Decodable {}
        do {
            let _: Empty = try await APIClient.shared.request(path: "/conversations/\(id)", method: "DELETE")
            conversations.removeAll { $0.id == id }
            if currentConversationId == id {
                currentConversationId = nil
                messages = []
            }
        } catch {
            print("Failed to delete conversation:", error)
        }
    }

    // MARK: - Chat

    func sendMessage(_ text: String) async {
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            conversationId: currentConversationId ?? "",
            role: .user,
            content: text,
            createdAt: Date()
        )
        messages.append(userMessage)

        isStreaming = true
        streamingText = ""

        do {
            try await APIClient.shared.streamChat(
                conversationId: currentConversationId,
                message: text,
                onText: { [weak self] chunk in
                    Task { @MainActor in
                        self?.streamingText += chunk
                    }
                },
                onConversationId: { [weak self] id in
                    Task { @MainActor in
                        self?.currentConversationId = id
                    }
                }
            )

            // Streaming complete — add assistant message
            let assistantMessage = ChatMessage(
                id: UUID().uuidString,
                conversationId: currentConversationId ?? "",
                role: .assistant,
                content: streamingText,
                createdAt: Date()
            )
            messages.append(assistantMessage)
        } catch {
            print("Stream error:", error)
        }

        isStreaming = false
        streamingText = ""
    }

    func startNewConversation() {
        currentConversationId = nil
        messages = []
    }
}
