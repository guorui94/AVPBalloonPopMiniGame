//
//  StartingInterface.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI

struct StartingInterface: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(AppModel.self) private var appModel
    @Binding var changeInterface: Bool
    @Binding var isStarting: Bool
    @State private var countdown: Int? = nil
    @State var gameEnds = false
    var onBack: () -> Void  // this sets the selected interface as nil (aka go back to ContentView)
    var onShowEndGame:
        (_ playAgain: @escaping () -> Void, _ backToMenu: @escaping () -> Void)
            -> Void

    var body: some View {
        ZStack {
            if !changeInterface {
                HStack {
                    Spacer()
                    VStack(spacing: 30) {
                        Spacer()
                        Text("🎈 Pop Balloons 🎈")
                            .font(.extraLargeTitle)
                            .fontWeight(.bold)

                        Text(
                            "You have 20 seconds to pop as many balloons as you can before they disappear at the top!"
                        )
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 800)
                        
                        HStack(spacing: 20) {
                            VStack (alignment: .leading) {
                                DisplayBalloonColors(color:BalloonColor.red.swiftColor, points: 5)

                                DisplayBalloonColors(color:BalloonColor.blue.swiftColor, points: 10)
                                
                                DisplayBalloonColors(color:BalloonColor.green.swiftColor, points: 15)
                            }

                            VStack {
                                DisplayBalloonColors(color:BalloonColor.darkBrown.swiftColor, points: 20)
                                
                                DisplayBalloonColors(color:BalloonColor.purple.swiftColor, points: 30)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.cyan)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.white.opacity(0.15))
                                            .padding(-4) // Makes background snug
                                    )

                                
                                DisplayBalloonColors(color:BalloonColor.teal.swiftColor, points: 50)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.cyan)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.white.opacity(0.15))
                                            .padding(-4) // Makes background snug
                                    )
                            }
                        }
                        
                        Text("Balloons with higher points will move much faster and push other balloons!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 800)

                        Button(action: {
                            startCountdown()
                        }) {
                            Group {
                                if let currentCount = countdown {
                                    Text("Starting in \(currentCount)...")
                                } else {
                                    Text("Let's Go!")
                                }
                            }
                            .font(.title)
                            .padding()
                            .frame(width: 200)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isStarting ? Color.clear : .white,
                                        lineWidth: 2.5)
                            )
                        }
                        .disabled(isStarting)
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    Spacer()
                }
                .padding(40)
                .glassBackgroundEffect(
                    in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                onBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 28, weight: .medium))
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .clipShape(Circle())
            .padding([.top, .leading], 20)
            .buttonStyle(.plain)
            .hoverEffect { effect, isActive, proxy in
                effect.scaleEffect(!isActive ? 1.0 : 1.2)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if changeInterface {
                ZStack(alignment: .topLeading) {
                    BalloonGameInterface(gameEnds: $gameEnds)
                    Button(action: {
                        changeInterface = false
                        isStarting = false
                        appModel.resetGame()
                        appModel.resetBalloonsRemoved()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .medium))
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .clipShape(Circle())
                    .padding([.top, .leading], 20)
                    .buttonStyle(.plain)
                    .hoverEffect { effect, isActive, proxy in
                        effect.scaleEffect(!isActive ? 1.0 : 1.2)
                    }
                }
                .offset(x: -250, y: -70)
            }
        }
        .onChange(of: gameEnds) { oldValue, newValue in
            onShowEndGame(
                {
                    resetGameState ()
                },
                {
                    onBack()
                    resetGameState ()
                })
        }
    }
    private func startCountdown() {
        countdown = 3
        isStarting = true
        Task {
            for i in (1...3).reversed() {
                countdown = i
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            countdown = nil

            await openImmersiveSpace(id: appModel.immersiveSpaceId)
            changeInterface = true
        }
    }
    private func resetGameState () {
        appModel.resetGame()
        changeInterface = false
        isStarting = false
        gameEnds = false
    }
    
}

#Preview {
    StartingInterface(
        changeInterface: .constant(false),
        isStarting: .constant(false),
        onBack: {},
        onShowEndGame: { playAgain, backToMenu in
        }
    )
    .environment(AppModel())
}
