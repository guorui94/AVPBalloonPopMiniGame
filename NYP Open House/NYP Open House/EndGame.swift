//
//  EndGame.swift
//  NYP Open House
//

import SwiftUI

struct EndGame: View {
    let displayScore: Int
    let gameTitle: String
    let playerInfo: AppModel.PlayerInfo?   // matches AppModel's nested type

    @Environment(AppModel.self) private var appModel

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Title
                Text(gameTitle)
                    .font(.extraLargeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
                    .multilineTextAlignment(.center)

                // Score
                Text("Your Score")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))

                Text("\(displayScore)")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                // Player details (from the name/email screen)
                if let p = playerInfo {
                    VStack(spacing: 4) {
                        Text("Player: \(p.name)")
                        Text(p.email)
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

                // Actions
                HStack(spacing: 16) {
                    Button("Play Again") {
                        appModel.isBalloonGame = false
                        appModel.isMemoryGame = false
                        appModel.gameEnds = false
                        appModel.currentScreen = .menu
                    }
                    .buttonStyle(.borderedProminent)

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
    }
}

#Preview {
    // Provide the required arguments so the preview builds.
    EndGame(
        displayScore: 100,
        gameTitle: "Balloon Frenzy",
        playerInfo: AppModel.PlayerInfo(name: "Preview Player", email: "preview@example.com")
    )
    .environment(AppModel())
}
