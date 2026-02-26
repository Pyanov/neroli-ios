import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isUser ? Color.accentColor : Color(.systemGray6))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            if !isUser { Spacer(minLength: 60) }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .opacity
        ))
        .sensoryFeedback(.impact(weight: .light), trigger: message.id)
    }
}

struct StreamingBubble: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    // Typing cursor
                    Circle()
                        .fill(.primary)
                        .frame(width: 6, height: 6)
                        .opacity(0.5)
                        .padding(8)
                        .phaseAnimator([false, true]) { content, phase in
                            content.opacity(phase ? 1 : 0.2)
                        } animation: { _ in .easeInOut(duration: 0.6) }
                }

            Spacer(minLength: 60)
        }
    }
}
