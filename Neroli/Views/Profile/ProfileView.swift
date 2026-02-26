import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationStack {
            List {
                // User info
                Section {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(.accent.opacity(0.2))
                            .frame(width: 56, height: 56)
                            .overlay {
                                Text(initials)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.accent)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(authService.currentUser?.displayName ?? "Neroli User")
                                .font(.headline)
                            if let email = authService.currentUser?.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Settings
                Section("Preferences") {
                    NavigationLink {
                        Text("Coming soon")
                    } label: {
                        Label("Notifications", systemImage: "bell.badge")
                    }

                    NavigationLink {
                        Text("Coming soon")
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                }

                // Memory
                Section("Memory") {
                    NavigationLink {
                        Text("Coming soon")
                    } label: {
                        Label("What Neroli knows about you", systemImage: "brain.head.profile")
                    }
                }

                // Account
                Section {
                    Button(role: .destructive) {
                        Task { await authService.signOut() }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    private var initials: String {
        let name = authService.currentUser?.displayName ?? "N"
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))"
        }
        return String(name.prefix(1)).uppercased()
    }
}
