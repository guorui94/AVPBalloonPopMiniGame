import SwiftUI
import RealityKit
import RealityKitContent
import FirebaseCore
import FirebaseFirestore

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        switch appModel.currentScreen {
        case .menu:
            mainMenuView

        case .balloonIntro:
            StartingInterface()

        case .memoryGame:
            Instructions()

        case .endGame:
            endGameView
        }
    }

    // MARK: - End Game Screen
    // Picks correct score + player info based on which game they just played.
    private var endGameView: some View {
        let isBalloon = appModel.isBalloonGame

        // Score for that game
        let score = isBalloon
            ? appModel.score.poppingScore
            : appModel.score.flipScore

        // Contact info for that game
        let info: AppModel.PlayerInfo? = isBalloon
            ? appModel.cachedBalloonContact
            : appModel.cachedMemoryContact

        // Title for that game
        let title = isBalloon
            ? "Balloon Frenzy"
            : "ARcade of Memories"

        return EndGame(
            displayScore: score,
            gameTitle: title,
            playerInfo: info
        )
    }

    // MARK: - Main Menu (no GameCard view)
    var mainMenuView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 32) {
                Spacer()

                // Header text
                VStack(spacing: 12) {
                    Text("Welcome!")
                        .font(.system(size: 80))
                        .fontWeight(.bold)

                    Text("Explore immersive games....")
                        .font(.title)
                }

                // Game launch buttons
                VStack(spacing: 24) {
                    Button {
                        appModel.currentScreen = .balloonIntro
                    } label: {
                        VStack(spacing: 4) {
                            Text("Balloon Frenzy")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("A battle between the fastest fingers")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)

                    Button {
                        appModel.currentScreen = .memoryGame
                    } label: {
                        VStack(spacing: 4) {
                            Text("Memory ARcade")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Match pairs to unlock NYP’s hidden gems.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
                .frame(maxWidth: 400)

                // Firebase connection test
                VStack(spacing: 8) {
                    Button("Verify Firebase Connection") {
                        Task {
                            // This calls the global helper that lives in FirebaseVerifier.swift (or whatever you named it).
                            await verifyFirebasePlistAndConnection()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)

                    Text("This prints Firebase project info and tries a Firestore read.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 220)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .glassBackgroundEffect(
                in: RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
            .onAppear {
                // When we land back in the menu, close any immersive space
                if appModel.immersiveSpaceState == .open {
                    Task { await dismissImmersiveSpace() }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
