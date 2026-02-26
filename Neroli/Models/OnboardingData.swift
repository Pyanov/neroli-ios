import Foundation

// MARK: - Onboarding Data Model

struct OnboardingData: Codable {
    var name: String = ""
    var lifeChapter: LifeChapter?
    var socialConfidence: SocialConfidence?
    var saturdayNight: [SaturdayNight] = []  // max 2
    var coachingStyle: CoachingStyle?

    var isComplete: Bool {
        !name.isEmpty && lifeChapter != nil && socialConfidence != nil && !saturdayNight.isEmpty && coachingStyle != nil
    }
}

// MARK: - Life Chapter

enum LifeChapter: String, Codable, CaseIterable, Identifiable {
    case singleLooking = "single_looking"
    case heartbreak = "heartbreak"
    case levelingUp = "leveling_up"
    case relationship = "relationship"
    case justVibing = "just_vibing"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .singleLooking: return "Single and trying to figure this out"
        case .heartbreak: return "Getting over someone"
        case .levelingUp: return "Leveling myself up"
        case .relationship: return "In a relationship, want to be better at it"
        case .justVibing: return "Just want someone real to talk to"
        }
    }

    var icon: String {
        switch self {
        case .singleLooking: return "heart.text.square"
        case .heartbreak: return "cloud.rain"
        case .levelingUp: return "arrow.up.forward"
        case .relationship: return "person.2"
        case .justVibing: return "bubble.left.and.bubble.right"
        }
    }
}

// MARK: - Social Confidence

enum SocialConfidence: String, Codable, CaseIterable, Identifiable {
    case wallflower = "wallflower"
    case slowWarm = "slow_warm"
    case selective = "selective"
    case socialButterfly = "social_butterfly"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wallflower: return "Find the dog or the bookshelf"
        case .slowWarm: return "Hover near a group until there's an opening"
        case .selective: return "Find one person who looks interesting and go deep"
        case .socialButterfly: return "I'm the one starting the conversation"
        }
    }

    var icon: String {
        switch self {
        case .wallflower: return "books.vertical"
        case .slowWarm: return "person.wave.2"
        case .selective: return "person.fill.questionmark"
        case .socialButterfly: return "star.bubble"
        }
    }
}

// MARK: - Saturday Night

enum SaturdayNight: String, Codable, CaseIterable, Identifiable {
    case active = "active"
    case social = "social"
    case creative = "creative"
    case chill = "chill"
    case growth = "growth"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: return "Gym, run, or pickup game"
        case .social: return "Bar, party, or dinner with friends"
        case .creative: return "Making something — music, code, cooking"
        case .chill: return "Couch, show, maybe a joint"
        case .growth: return "Reading, journaling, working on myself"
        }
    }

    var icon: String {
        switch self {
        case .active: return "figure.run"
        case .social: return "wineglass"
        case .creative: return "paintbrush.pointed"
        case .chill: return "sofa"
        case .growth: return "brain.head.profile"
        }
    }
}

// MARK: - Coaching Style

enum CoachingStyle: String, Codable, CaseIterable, Identifiable {
    case drillSergeant = "drill_sergeant"
    case wiseFriend = "wise_friend"
    case hypeMan = "hype_man"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .drillSergeant: return "A drill sergeant"
        case .wiseFriend: return "A wise friend"
        case .hypeMan: return "A hype man"
        }
    }

    var subtitle: String {
        switch self {
        case .drillSergeant: return "Push me. I can take it."
        case .wiseFriend: return "Be real, but be kind about it."
        case .hypeMan: return "Gas me up, then give me the plan."
        }
    }

    var icon: String {
        switch self {
        case .drillSergeant: return "flame"
        case .wiseFriend: return "cup.and.saucer"
        case .hypeMan: return "hands.clap"
        }
    }

    /// Maps to the communicationStyle stored in the DB
    var communicationStyle: String {
        switch self {
        case .drillSergeant: return "direct"
        case .wiseFriend: return "balanced"
        case .hypeMan: return "supportive"
        }
    }
}

// MARK: - Value Moment Insights

struct OnboardingInsight {
    /// Generate a multi-dimensional personalized insight based on all onboarding answers
    static func generate(for data: OnboardingData) -> String {
        guard let chapter = data.lifeChapter else {
            return "I'm here whenever you need to talk. No topic is off limits."
        }

        var parts: [String] = []

        // 1. Life chapter opener
        parts.append(lifeChapterOpener(chapter))

        // 2. Social observation
        if let social = data.socialConfidence {
            parts.append(socialObservation(social))
        }

        // 3. Lifestyle texture
        if !data.saturdayNight.isEmpty {
            parts.append(lifestyleTexture(data.saturdayNight))
        }

        // 4. Coaching hook
        if let style = data.coachingStyle {
            parts.append(coachingHook(style, chapter: chapter))
        }

        return parts.joined(separator: " ")
    }

    /// Generate a compact personality digest for the API
    static func generateDigest(for data: OnboardingData) -> String {
        var traits: [String] = []

        if let social = data.socialConfidence {
            switch social {
            case .wallflower: traits.append("Introverted")
            case .slowWarm: traits.append("Introverted-leaning")
            case .selective: traits.append("Selectively social")
            case .socialButterfly: traits.append("Extroverted")
            }
        }

        if let chapter = data.lifeChapter {
            switch chapter {
            case .singleLooking: traits.append("single guy actively dating")
            case .heartbreak: traits.append("recovering from a breakup")
            case .levelingUp: traits.append("focused on self-improvement")
            case .relationship: traits.append("in a relationship working on it")
            case .justVibing: traits.append("looking for genuine connection")
            }
        }

        var lifestyle: [String] = []
        for item in data.saturdayNight {
            switch item {
            case .active: lifestyle.append("exercise and sports")
            case .social: lifestyle.append("social outings")
            case .creative: lifestyle.append("creative projects")
            case .chill: lifestyle.append("downtime and relaxation")
            case .growth: lifestyle.append("reading and self-work")
            }
        }

        var digest = traits.joined(separator: " ")
        if !lifestyle.isEmpty {
            digest += " who recharges through \(lifestyle.joined(separator: " and "))"
        }

        if let social = data.socialConfidence {
            switch social {
            case .wallflower: digest += ". Needs space to open up but has depth when comfortable."
            case .slowWarm: digest += ". Warms up slowly but goes deep when he connects."
            case .selective: digest += ". Goes deep one-on-one, skips surface-level."
            case .socialButterfly: digest += ". Confident socially, ready to dive in."
            }
        }

        if let style = data.coachingStyle {
            switch style {
            case .drillSergeant: digest += " Wants direct, no-BS guidance."
            case .wiseFriend: digest += " Wants honest guidance delivered with warmth."
            case .hypeMan: digest += " Wants encouragement first, then the real talk."
            }
        }

        return digest
    }

    // MARK: - Fragment Builders

    private static func lifeChapterOpener(_ chapter: LifeChapter) -> String {
        switch chapter {
        case .singleLooking:
            return "You're in the thick of figuring out dating — that's one of the hardest things to navigate honestly."
        case .heartbreak:
            return "Getting over someone takes more than time — it takes the right kind of processing."
        case .levelingUp:
            return "You're in build mode right now, and that energy is powerful when it's aimed well."
        case .relationship:
            return "Wanting to be better in a relationship is a sign you're already better than most."
        case .justVibing:
            return "Sometimes the best thing you can do is find someone real to think out loud with."
        }
    }

    private static func socialObservation(_ social: SocialConfidence) -> String {
        switch social {
        case .wallflower:
            return "You're not anti-social — you just need space to warm up, and that's actually a strength once people get past the surface."
        case .slowWarm:
            return "You observe before you engage — that means when you do connect, it's real."
        case .selective:
            return "You go deep with the right person rather than wide with everyone — that's how the best relationships work."
        case .socialButterfly:
            return "You've got the social confidence a lot of guys wish they had — now it's about channeling that energy."
        }
    }

    private static func lifestyleTexture(_ items: [SaturdayNight]) -> String {
        let descriptions = items.map { item -> String in
            switch item {
            case .active: return "staying active"
            case .social: return "being around people"
            case .creative: return "making things"
            case .chill: return "recharging on your own terms"
            case .growth: return "investing in yourself"
            }
        }

        if descriptions.count == 2 {
            return "The fact that your ideal night involves \(descriptions[0]) and \(descriptions[1]) tells me a lot about your balance."
        } else if let first = descriptions.first {
            return "The fact that your ideal night involves \(first) tells me something about what you value."
        }
        return ""
    }

    private static func coachingHook(_ style: CoachingStyle, chapter: LifeChapter) -> String {
        switch style {
        case .drillSergeant:
            return "I'll be straight with you — no sugarcoating, no filler. Let's get to work."
        case .wiseFriend:
            return "I'll be honest with you, but I'll be kind about it. That's how I'd want someone to be with me."
        case .hypeMan:
            return "I've got you. We're going to build you up AND give you the real talk. Both at the same time."
        }
    }
}
