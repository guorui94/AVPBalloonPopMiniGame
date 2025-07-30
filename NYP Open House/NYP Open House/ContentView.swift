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
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        switch appModel.currentScreen {
        case .menu:
            mainMenuView
        case .balloonIntro:
            StartingInterface()
        case .endGame:
            let score = appModel.score.poppingScore > 0 ? appModel.score.poppingScore : appModel.score.flipScore
            EndGame(displayScore: score)
        case .memoryGame:
            Instructions()
        }
    }

    var mainMenuView: some View {
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
                    title: "Balloon Popping",
                    subtitle: "A battle between the fastest fingers",
                    action: {
                        appModel.currentScreen = .balloonIntro
                    })

                GameCard(
                    title: "Memory Game",
                    subtitle: "Game descriptions here...",
                    action: {
                        appModel.currentScreen = .memoryGame
                    })

                GameCard(
                    title: "Game 3",
                    subtitle: "Game descriptions here...",
                    action: {
                        // to add in the future
                    })

                Spacer()
            }

            Spacer()
        }
        .padding()
        .glassBackgroundEffect(
            in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
