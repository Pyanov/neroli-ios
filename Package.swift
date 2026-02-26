// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NeroliDependencies",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NeroliDependencies", targets: ["NeroliDependencies"]),
    ],
    dependencies: [
        // Animation & Effects
        .package(url: "https://github.com/EmergeTools/Pow.git", from: "1.0.0"),
        .package(url: "https://github.com/jtrivedi/Wave.git", from: "0.1.0"),
        .package(url: "https://github.com/twostraws/Vortex.git", from: "1.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.4.0"),

        // Chat UI
        .package(url: "https://github.com/exyte/Chat.git", from: "2.0.0"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.3.0"),

        // Navigation & UI
        .package(url: "https://github.com/exyte/PopupView.git", from: "3.0.0"),
        .package(url: "https://github.com/exyte/AnimatedTabBar.git", from: "1.0.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer.git", from: "1.4.0"),

        // Networking
        .package(url: "https://github.com/mattt/EventSource.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "NeroliDependencies",
            dependencies: [
                "Pow",
                "Wave",
                "Vortex",
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "ExyteChat", package: "Chat"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                "PopupView",
                "AnimatedTabBar",
                .product(name: "Shimmer", package: "SwiftUI-Shimmer"),
                "EventSource",
            ]
        ),
    ]
)
