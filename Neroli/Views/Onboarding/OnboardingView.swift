import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showEmailAuth = false

    var body: some View {
        ZStack {
            // Animated mesh gradient background
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1],
                    ],
                    colors: [
                        .black, .indigo.opacity(0.6), .black,
                        .indigo.opacity(0.4), .purple.opacity(0.3), .indigo.opacity(0.4),
                        .black, .indigo.opacity(0.6), .black,
                    ]
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(colors: [.black, .indigo.opacity(0.3), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }

            VStack(spacing: 32) {
                Spacer()

                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers)

                    Text("Neroli")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your guide to becoming\nthe man you want to be.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Auth buttons
                VStack(spacing: 14) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        Task { await authService.handleAppleSignIn(result: result) }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button {
                        showEmailAuth = true
                    } label: {
                        Text("Continue with Email")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    if let error = authService.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView()
                .environmentObject(authService)
        }
    }
}
