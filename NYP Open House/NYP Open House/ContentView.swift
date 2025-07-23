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
    @State private var selectedInterface: AnyView?
    @State var changeInterface = false
    @State var isStarting = false
    var body: some View {
        if let interface = selectedInterface {
            interface
        } else {
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
                        action: { showStartingInterface()
                        })

                    GameCard(
                        title: "Memory Game", subtitle: "Game descriptions here...",
                        action: {
                            Task {
                                await openImmersiveSpace(id: Module.memoryFlippingSpace.name)
                            }
                        })
                    
                    // filler
                    GameCard(
                        title: "Game 3", subtitle: "Game descriptions here...",
                        action: {
                            // to add in the future

                        })

                    Spacer()
                }

                Spacer()

            }
            .padding()
            .glassBackgroundEffect(
                in: RoundedRectangle(
                    cornerRadius: 32,
                    style: .continuous
                )
            )
        }
        
    }
    private func showStartingInterface() {
        selectedInterface = AnyView(
            StartingInterface(
                changeInterface: $changeInterface,
                isStarting: $isStarting,
                onBack: {
                    selectedInterface = nil
                },
                onShowEndGame: { playAgain, backToMenu in
                    selectedInterface = AnyView(
                        BalloonEndGame(
                            onPlayAgain: {
                                appModel.resetBalloonGame()
                                changeInterface = false
                                isStarting = false
                                showStartingInterface()
                            },
                            onBackToMenu: {
                                Task {
                                    await dismissImmersiveSpace()
                                }
                                appModel.resetBalloonGame()
                                changeInterface = false
                                isStarting = false
                                selectedInterface = nil
                            }
                        )
                    )
                }
            )
        )
    }
    
}

#Preview() {
    ContentView()
        .environment(AppModel())
}

