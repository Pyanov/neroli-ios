import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .chat
    @Published var isLoading = false

    enum Tab: Int, CaseIterable {
        case chat
        case profile
    }
}
