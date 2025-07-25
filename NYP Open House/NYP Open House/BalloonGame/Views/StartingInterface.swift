//
//  StartingInterface.swift
//  NYP Open House
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI

struct StartingInterface: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var isStarting = false
    @State private var countdown: Int? = nil
    @State private var fadeOutOverlayOpacity: Double = 0.0

    var body: some View {
        ZStack {
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
                        
                        HStack() {
                            VStack (alignment: .leading) {
                                DisplayBalloonColors(color:BalloonColor.red.swiftColor, points: BalloonColor.red.poppingScore)

                                
                                DisplayBalloonColors(color:BalloonColor.green.swiftColor, points: BalloonColor.green.poppingScore)
                            }

                            VStack (alignment: .leading) {
                                DisplayBalloonColors(color:BalloonColor.purple.swiftColor, points: BalloonColor.purple.poppingScore)

                                
                                DisplayBalloonColors(color:BalloonColor.gold.swiftColor, points: BalloonColor.gold.poppingScore)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.cyan)
                            }
                        }

                        Text("Balloons with higher points move faster and push other balloons.")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 700)

                        Text("Balloons will start blinking when they're about to fly away — pop them quickly!")
                            .font(.title2)
                            .foregroundStyle(.cyan)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 650)
                            .padding(.bottom, 10)

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
            Color.black
                .opacity(fadeOutOverlayOpacity)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: fadeOutOverlayOpacity)
            
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                appModel.currentScreen = .menu
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
        .onChange(of: appModel.gameEnds) { oldValue, newValue in
            resetGameState ()
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
            fadeOutOverlayOpacity = 1.0
            await openImmersiveSpace(id: Module.bubbleSpace.name)
            dismissWindow(id: "content")
        }
    }
    private func resetGameState () {
        appModel.resetBalloonGame()
        isStarting = false
        appModel.gameEnds = false
    }
    
}

#Preview {
    StartingInterface()
        .environment(AppModel())
}

