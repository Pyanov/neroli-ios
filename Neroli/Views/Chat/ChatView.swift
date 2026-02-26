import SwiftUI

struct ChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if chatService.messages.isEmpty && !chatService.isStreaming {
                                EmptyStateView()
                            }

                            ForEach(chatService.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            // Streaming message
                            if chatService.isStreaming && !chatService.streamingText.isEmpty {
                                StreamingBubble(text: chatService.streamingText)
                                    .id("streaming")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: chatService.messages.count) {
                        withAnimation(.spring(response: 0.3)) {
                            proxy.scrollTo(chatService.messages.last?.id ?? "streaming", anchor: .bottom)
                        }
                    }
                    .onChange(of: chatService.streamingText) {
                        proxy.scrollTo("streaming", anchor: .bottom)
                    }
                }

                // Input bar
                ChatInputBar(
                    text: $inputText,
                    isFocused: $isInputFocused,
                    isStreaming: chatService.isStreaming,
                    onSend: {
                        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !message.isEmpty else { return }
                        inputText = ""
                        Task { await chatService.sendMessage(message) }
                    }
                )
            }
            .navigationTitle("Neroli")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        chatService.startNewConversation()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .symbolEffect(.bounce, value: chatService.messages.isEmpty)
                    }
                }
            }
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 100)

            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .symbolEffect(.variableColor.iterative)

            Text("What's on your mind?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Dating, confidence, career, fitness —\nI'm here to help you level up.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }
}
