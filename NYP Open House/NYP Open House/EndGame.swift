import SwiftUI

struct EndGame: View {
    let displayScore: Int
    let gameTitle: String
    let playerInfo: AppModel.PlayerInfo?   // comes from AppModel

    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    // Countdown state for replay button
    @State private var isRestarting: Bool = false
    @State private var restartCountdown: Int? = nil
    @State private var hasSavedSession = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Game title
                Text(gameTitle)
                    .font(.extraLargeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
                    .multilineTextAlignment(.center)

                // Score section
                Text("Your Score")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))

                Text("\(displayScore)")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                // Player info
                if let p = playerInfo {
                    VStack(spacing: 4) {
                        Text("Player: \(p.name)")
                        Text(p.phone)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                } else {
                    Text("Player: (not provided)")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                // Replay and Close buttons
                HStack(spacing: 16) {
                    Button(action: { handlePlayAgainTap() }) {
                        Group {
                            if let c = restartCountdown {
                                Text("Starting in \(c)...")
                            } else {
                                Text("Play Again")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRestarting)
                    .accessibilityHint("Start a new round of the same game")

                    Button("Close") {
                        appModel.isBalloonGame = false
                        appModel.isMemoryGame = false
                        appModel.gameEnds = false
                        appModel.currentScreen = .menu
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 800)
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
        .onAppear {
            // Save to Firestore once per appearance
            if !hasSavedSession {
                hasSavedSession = true

                Task {
                    do {
                        try await SessionService.saveSession(
                            name: playerInfo?.name ?? "Unknown Player",
                            phone: playerInfo?.phone ?? "N/A",
                            gameType: gameTitle,
                            score: displayScore
                        )

                        print("Session saved to Firestore ✅")
                    } catch {
                        print("❌ Firestore save failed:", error.localizedDescription)
                    }
                }

                // Also update local model history
                appModel.finalizeCurrentSession()
            }
        }
    }

    // MARK: - Replay logic
    private func handlePlayAgainTap() {
        if appModel.isBalloonGame {
            // If we already have balloon contact, skip back to game immediately
            guard appModel.cachedBalloonContact != nil else {
                appModel.currentScreen = .balloonIntro
                return
            }
            startRestartCountdown(isBalloon: true)

        } else if appModel.isMemoryGame {
            // If we already have memory contact, skip back to game immediately
            guard appModel.cachedMemoryContact != nil else {
                appModel.currentScreen = .memoryGame
                return
            }
            startRestartCountdown(isBalloon: false)

        } else {
            // Fallback to menu
            appModel.currentScreen = .menu
        }
    }

    private func startRestartCountdown(isBalloon: Bool) {
        isRestarting = true
        restartCountdown = 3

        Task {
            for i in (1...3).reversed() {
                restartCountdown = i
                try? await Task.sleep(for: .seconds(1))
            }
            restartCountdown = nil

            if isBalloon {
                // Reset session for balloon game
                appModel.startBalloonSession()
                _ = await openImmersiveSpace(id: Module.bubbleSpace.name)
            } else {
                // Reset session for memory game
                appModel.startMemorySession()
                _ = await openImmersiveSpace(id: Module.memorySpace.name)
            }

            dismissWindow(id: "content")
            isRestarting = false
        }
    }
}

#Preview {
    EndGame(
        displayScore: 100,
        gameTitle: "Balloon Frenzy",
        playerInfo: AppModel.PlayerInfo(name: "Preview Player", phone: "+65 9123 4567")
    )
    .environment(AppModel())
}
