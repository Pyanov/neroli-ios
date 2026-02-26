import SwiftUI

@main
struct NeroliApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    MainTabView()
                        .environmentObject(authService)
                        .environmentObject(appState)
                } else {
                    OnboardingView()
                        .environmentObject(authService)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authService.isAuthenticated)
        }
    }
}
