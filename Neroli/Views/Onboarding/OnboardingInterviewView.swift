import SwiftUI

// MARK: - Onboarding Interview Container

struct OnboardingInterviewView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var appState: AppState
    @State private var currentStep: InterviewStep = .welcome
    @State private var data = OnboardingData()
    @State private var direction: TransitionDirection = .forward
    @State private var isSaving = false

    enum InterviewStep: Int, CaseIterable, Equatable {
        case welcome
        case name
        case lifeChapter
        case socialConfidence
        case saturdayNight
        case coachingStyle
        case valueMoment
    }

    enum TransitionDirection {
        case forward, backward
    }

    var body: some View {
        ZStack {
            NeroliTheme.Colors.background
                .ignoresSafeArea()

            // Step Content
            Group {
                switch currentStep {
                case .welcome:
                    welcomeStep
                case .name:
                    nameStep
                case .lifeChapter:
                    lifeChapterStep
                case .socialConfidence:
                    socialConfidenceStep
                case .saturdayNight:
                    saturdayNightStep
                case .coachingStyle:
                    coachingStyleStep
                case .valueMoment:
                    valueMomentStep
                }
            }
            .id(currentStep)
            .transition(
                .asymmetric(
                    insertion: .move(edge: direction == .forward ? .trailing : .leading)
                        .combined(with: .opacity),
                    removal: .move(edge: direction == .forward ? .leading : .trailing)
                        .combined(with: .opacity)
                )
            )

            // Back button (top left, after welcome)
            if currentStep != .welcome {
                VStack {
                    HStack {
                        Button(action: goBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(NeroliTheme.Colors.textSecondary)
                                .frame(width: 40, height: 40)
                                .background(NeroliTheme.Colors.surface)
                                .clipShape(Circle())
                        }
                        Spacer()

                        // Progress dots
                        progressDots
                        Spacer()

                        // Spacer for symmetry
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Spacer()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        let totalSteps = stepsForCurrentFlow.count
        let currentIndex = stepsForCurrentFlow.firstIndex(of: currentStep) ?? 0

        return HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(
                        index <= currentIndex
                            ? NeroliTheme.Colors.accent
                            : NeroliTheme.Colors.textTertiary
                    )
                    .frame(width: index == currentIndex ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
            }
        }
    }

    /// Always 7 screens — no conditional steps
    private var stepsForCurrentFlow: [InterviewStep] {
        InterviewStep.allCases
    }

    // MARK: - Welcome Step

    private var welcomeStep: some View {
        WelcomeStepView(onNext: { goForward(to: .name) })
    }

    // MARK: - Name Step

    private var nameStep: some View {
        OnboardingStepView(
            title: "What should I call you?",
            buttonTitle: "Next",
            buttonEnabled: !data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onNext: { goForward(to: .lifeChapter) }
        ) {
            NameInputField(name: $data.name)
        }
        .padding(.top, 56)
    }

    // MARK: - Life Chapter Step

    private var lifeChapterStep: some View {
        let displayName = data.name.trimmingCharacters(in: .whitespacesAndNewlines)

        return OnboardingStepView(
            title: "Where are you at right now, \(displayName)?",
            buttonTitle: "Next",
            buttonEnabled: data.lifeChapter != nil,
            onNext: { goForward(to: .socialConfidence) }
        ) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(LifeChapter.allCases) { chapter in
                        SelectionCard(
                            title: chapter.title,
                            icon: chapter.icon,
                            isSelected: data.lifeChapter == chapter,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    data.lifeChapter = chapter
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(.top, 56)
    }

    // MARK: - Social Confidence Step

    private var socialConfidenceStep: some View {
        OnboardingStepView(
            title: "You're at a party where you don't know anyone. You...",
            buttonTitle: "Next",
            buttonEnabled: data.socialConfidence != nil,
            onNext: { goForward(to: .saturdayNight) }
        ) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(SocialConfidence.allCases) { confidence in
                        SelectionCard(
                            title: confidence.title,
                            icon: confidence.icon,
                            isSelected: data.socialConfidence == confidence,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    data.socialConfidence = confidence
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(.top, 56)
    }

    // MARK: - Saturday Night Step (Multi-select, max 2)

    private var saturdayNightStep: some View {
        OnboardingStepView(
            title: "It's Saturday night. Your ideal version looks like...",
            subtitle: "Pick up to 2",
            buttonTitle: "Next",
            buttonEnabled: !data.saturdayNight.isEmpty,
            onNext: { goForward(to: .coachingStyle) }
        ) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(SaturdayNight.allCases) { activity in
                        SelectionCard(
                            title: activity.title,
                            icon: activity.icon,
                            isSelected: data.saturdayNight.contains(activity),
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if data.saturdayNight.contains(activity) {
                                        data.saturdayNight.removeAll { $0 == activity }
                                    } else if data.saturdayNight.count < 2 {
                                        data.saturdayNight.append(activity)
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(.top, 56)
    }

    // MARK: - Coaching Style Step

    private var coachingStyleStep: some View {
        OnboardingStepView(
            title: "When I give you advice, I should be more like...",
            buttonTitle: "Next",
            buttonEnabled: data.coachingStyle != nil,
            onNext: { goForward(to: .valueMoment) }
        ) {
            VStack(spacing: 10) {
                ForEach(CoachingStyle.allCases) { style in
                    SelectionCard(
                        title: style.title,
                        subtitle: style.subtitle,
                        icon: style.icon,
                        isSelected: data.coachingStyle == style,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                data.coachingStyle = style
                            }
                        }
                    )
                }
            }
        }
        .padding(.top, 56)
    }

    // MARK: - Value Moment Step

    private var valueMomentStep: some View {
        let displayName = data.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let insight = OnboardingInsight.generate(for: data)

        let ctaText: String = {
            switch data.coachingStyle {
            case .drillSergeant: return "Let's get to work"
            case .hypeMan: return "Let's do this"
            case .wiseFriend, .none: return "Start chatting with Neroli"
            }
        }()

        return ValueMomentStepView(
            name: displayName,
            insight: insight,
            ctaText: ctaText,
            isSaving: isSaving,
            onStart: completeOnboarding
        )
    }

    // MARK: - Navigation

    private func goForward(to step: InterviewStep) {
        direction = .forward
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentStep = step
        }
    }

    private func goBack() {
        direction = .backward
        let steps = stepsForCurrentFlow
        guard let currentIndex = steps.firstIndex(of: currentStep), currentIndex > 0 else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentStep = steps[currentIndex - 1]
        }
    }

    // MARK: - Complete

    private func completeOnboarding() {
        isSaving = true
        Task {
            do {
                try await APIClient.shared.saveOnboarding(data: data)
            } catch {
                // Silently continue — onboarding data is nice-to-have, not blocking
                print("Failed to save onboarding: \(error)")
            }
            await MainActor.run {
                isSaving = false
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                    appState.needsOnboarding = false
                }
            }
        }
    }
}

// MARK: - Welcome Step View

private struct WelcomeStepView: View {
    let onNext: () -> Void

    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showTertiary = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Brand section
            VStack(spacing: 28) {
                // Neroli wordmark
                Text("N")
                    .font(NeroliTheme.Font.display(64))
                    .foregroundStyle(NeroliTheme.Colors.accent)
                    .frame(width: 88, height: 88)
                    .background(NeroliTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .opacity(showLogo ? 1 : 0)
                    .scaleEffect(showLogo ? 1 : 0.8)

                VStack(spacing: 16) {
                    Text("Hey, I'm Neroli.")
                        .font(NeroliTheme.Font.display(32))
                        .foregroundStyle(NeroliTheme.Colors.textPrimary)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 12)

                    Text("I help guys figure out dating, style,\nfitness, and everything else no one\nteaches you.")
                        .font(NeroliTheme.Font.regular(16))
                        .foregroundStyle(NeroliTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 8)

                    Text("Let me get to know you a bit first.")
                        .font(NeroliTheme.Font.regular(15))
                        .foregroundStyle(NeroliTheme.Colors.textTertiary)
                        .opacity(showTertiary ? 1 : 0)
                        .offset(y: showTertiary ? 0 : 8)
                }
            }

            Spacer()
            Spacer()

            // CTA
            Button(action: onNext) {
                Text("Let's go")
                    .font(NeroliTheme.Font.medium(16))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(NeroliTheme.Colors.userBubbleText)
                    .background(NeroliTheme.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.15)) { showLogo = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) { showTitle = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) { showSubtitle = true }
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) { showTertiary = true }
            withAnimation(.easeOut(duration: 0.6).delay(1.3)) { showButton = true }
        }
    }
}

// MARK: - Name Input Field

private struct NameInputField: View {
    @Binding var name: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("", text: $name, prompt: Text("Your name")
            .foregroundStyle(NeroliTheme.Colors.textTertiary)
        )
        .font(NeroliTheme.Font.regular(18))
        .foregroundStyle(NeroliTheme.Colors.textPrimary)
        .tint(NeroliTheme.Colors.accent)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(NeroliTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    isFocused ? NeroliTheme.Colors.accent : NeroliTheme.Colors.separator,
                    lineWidth: isFocused ? 1.5 : 0.5
                )
        )
        .focused($isFocused)
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled()
        .submitLabel(.done)
        .onAppear {
            // Show keyboard after a brief delay for the animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Value Moment Step View

private struct ValueMomentStepView: View {
    let name: String
    let insight: String
    let ctaText: String
    let isSaving: Bool
    let onStart: () -> Void

    @State private var showTitle = false
    @State private var showInsight = false
    @State private var showButton = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                Text("Here's what I see, \(name).")
                    .font(NeroliTheme.Font.display(28))
                    .foregroundStyle(NeroliTheme.Colors.textPrimary)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 12)

                Text(insight)
                    .font(NeroliTheme.Font.regular(17))
                    .foregroundStyle(NeroliTheme.Colors.textSecondary)
                    .lineSpacing(6)
                    .opacity(showInsight ? 1 : 0)
                    .offset(y: showInsight ? 0 : 10)
            }

            Spacer()
            Spacer()

            // CTA
            Button(action: onStart) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .tint(NeroliTheme.Colors.userBubbleText)
                            .scaleEffect(0.9)
                    }
                    Text(ctaText)
                        .font(NeroliTheme.Font.medium(16))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(NeroliTheme.Colors.userBubbleText)
                .background(NeroliTheme.Colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(isSaving)
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 20)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) { showTitle = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) { showInsight = true }
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) { showButton = true }
        }
    }
}
