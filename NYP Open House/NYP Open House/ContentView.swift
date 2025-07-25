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
        case .balloonEnd:
            BalloonEndGame()
        case .memoryGame:
            EmptyView() 
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
                        Task {
                            await openImmersiveSpace(id: Module.memoryFlippingSpace.name)
                            dismissWindow(id: "content")
                            appModel.currentScreen = .memoryGame
                        }
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
        .opacity(appModel.isMemoryGame ? 0 : 1)
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
