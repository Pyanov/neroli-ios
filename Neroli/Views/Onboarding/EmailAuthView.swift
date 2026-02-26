import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isRegistering {
                    TextField("Name", text: $displayName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                }

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(isRegistering ? .newPassword : .password)

                Button {
                    Task {
                        if isRegistering {
                            await authService.register(email: email, password: password, displayName: displayName.isEmpty ? nil : displayName)
                        } else {
                            await authService.login(email: email, password: password)
                        }
                        if authService.isAuthenticated { dismiss() }
                    }
                } label: {
                    Text(isRegistering ? "Create Account" : "Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(authService.isLoading || email.isEmpty || password.isEmpty)

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isRegistering.toggle()
                    }
                } label: {
                    Text(isRegistering ? "Already have an account? Sign in" : "Don't have an account? Register")
                        .font(.subheadline)
                }

                if let error = authService.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .navigationTitle(isRegistering ? "Create Account" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
