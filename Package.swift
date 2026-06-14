// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GitHubCopilotLLMSwitch",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "GitHubCopilotLLMSwitch",
            targets: ["GitHubCopilotLLMSwitch"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "GitHubCopilotLLMSwitch",
            path: ".",
            exclude: [
                "dist",
                "LICENSE",
                "README.md",
                "Tests",
                "script",
            ],
            sources: [
                "App",
                "Models",
                "Services",
                "Stores",
                "Support",
                "Views",
            ]
        ),
        .testTarget(
            name: "GitHubCopilotLLMSwitchTests",
            dependencies: ["GitHubCopilotLLMSwitch"],
            path: "Tests/GitHubCopilotLLMSwitchTests"
        ),
    ]
)
