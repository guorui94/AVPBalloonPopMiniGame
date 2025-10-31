//
//  ContentView.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

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

        case .endGame:
            endGameView   // keep the switch body clean

        case .memoryGame:
            Instructions()
        }
    }

    // MARK: - End Game (choose correct score + contact)
    private var endGameView: some View {
        let isBalloon = appModel.isBalloonGame
        // Pick the score *for that game only*
        let score = isBalloon ? appModel.score.poppingScore : appModel.score.flipScore

        let info: AppModel.PlayerInfo? = isBalloon
            ? appModel.cachedBalloonContact
            : appModel.cachedMemoryContact

        let title = isBalloon ? "Balloon Frenzy" : "ARcade of Memories"

        return EndGame(displayScore: score, gameTitle: title, playerInfo: info)
    }

    // MARK: - Main Menu
    var mainMenuView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 20) {
                Spacer()

                Text("Welcome!")
                    .font(.system(size: 80))
                    .fontWeight(.bold)

                Text("Explore immersive games....")
                    .font(.title)
                    .padding(.bottom, 20)

                HStack(spacing: 50) {
                    Spacer()

                    GameCard(
                        title: "Balloon Frenzy",
                        subtitle: "A battle between the fastest fingers",
                        action: {
                            appModel.currentScreen = .balloonIntro
                        })

                    GameCard(
                        title: "Memory ARcade",
                        subtitle: "Match pairs to unlock NYP’s hidden gems.",
                        action: {
                            appModel.currentScreen = .memoryGame
                        })

                    Spacer()
                }

                Spacer()
            }
            .padding()
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .onAppear {
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
