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

    // MARK: - Main Menu (dimensions aligned with game screens)
    var mainMenuView: some View {
        ZStack {
            GeometryReader { geo in
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
                    // similar “content width” to StartingInterface
                    .frame(maxWidth: 600)

                    Spacer()
                }
                // match the kind of layout you used in StartingInterface
                .frame(maxWidth: 1100)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(minHeight: geo.size.height, alignment: .center)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .onAppear {
                    // When we land back in the menu, close any immersive space
                    if appModel.immersiveSpaceState == .open {
                        Task { await dismissImmersiveSpace() }
                    }
                }
            }
        }
        .glassBackgroundEffect(
            in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
