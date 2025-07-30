//
//  MemoryGameOverlay.swift
//  NYP Open House
//
//  Created by Amelia on 22/7/25.
//

import SwiftUI

struct MemoryGameOverlay: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    @State private var progress = 1.0
    @State private var triggerColorChange = false
    @State private var isPulsing = false
    @Binding var currentGameMode: GameModes
    @State private var secondsRemaining: Int = 0

    var body: some View {
        let totalTime = currentGameMode.timer

        let displayScore = appModel.score

        VStack {
            Spacer()
            VStack(spacing: 8) {
                Text(
                    verbatim: "\(String(format: "%02d", displayScore.flipScore))"
                )
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)

                Text("Score")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.secondary)

                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .stroke(
                                triggerColorChange
                                    ? Color.red : Color.white.opacity(0.7),
                                lineWidth: 2
                            )
                            .frame(width: 285, height: 9)

                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 280, height: 12)
                            .padding(.horizontal, 30)
                            .tint(
                                triggerColorChange
                                    ? Color(
                                        hue: 0.0, saturation: 0.3, brightness: 1.0)
                                    : .cyan)

                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .scaleEffect(isPulsing ? 1.05 : 1.0)
                    .animation(
                        triggerColorChange
                            ? .easeInOut(duration: 1.0).repeatForever(
                                autoreverses: true)
                            : .default,
                        value: isPulsing
                    )

                    HStack {
                        let minutes = Int(secondsRemaining) / 60
                        let seconds = Int(secondsRemaining) % 60

                        Label(
                            "\(String(format: "%02d:%02d", minutes, seconds))",
                            systemImage: "hourglass.tophalf.fill"
                        )
                        .font(.headline)
                        .foregroundStyle(triggerColorChange ? .red : .white)
                        Text("Seconds Remaining")
                            .font(.headline)
                            .foregroundStyle(triggerColorChange ? .red : .white)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .overlay(alignment: .topLeading) {
                Button(action: {
                    appModel.currentScreen = .menu
                    Task {
                        openWindow(id:"content")
                        await dismissImmersiveSpace()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 28, weight: .medium))
                        .padding(14)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .clipShape(Circle())
                .padding(.top, 10)
                .padding(.leading, 50)
                .buttonStyle(.plain)
                .hoverEffect { effect, isActive, proxy in
                    effect.scaleEffect(!isActive ? 1.0 : 1.2)
                }
            }
            .frame(width: 330)
            .glassBackgroundEffect(in: .rect(cornerRadius: 32))
        }
        .onReceive(timer) { _ in
            if progress > 0.0 {
                progress -= 1 / totalTime
                if progress <= 0.0 {
                    progress = 0.0
                }

                if appModel.gameEnds || appModel.currentGameMode == nil {
                    prepareForEndGame()
                }

                secondsRemaining -= 1
                if secondsRemaining <= 5 {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        triggerColorChange = true
                        isPulsing = true
                    }
                }
            } else {
                prepareForEndGame()
            }
        }
        .onAppear {
            secondsRemaining = Int(currentGameMode.timer)
            progress = 1.0
        }
        .onChange(of: currentGameMode, { oldMode, newMode in
            secondsRemaining = Int(newMode.timer)
            progress = 1.0
        })
    }
    func prepareForEndGame() {
        appModel.currentScreen = .endGame
        if appModel.immersiveSpaceState == .open {
            Task {
                openWindow(id:"content")
                appModel.gameEnds = true
                await dismissImmersiveSpace()
                appModel.currentGameMode = .easy
            }
        }
        appModel.signalEndGame()
        timer.upstream.connect().cancel()
        appModel.pose.stopTracking()
    }
}

#Preview {
    MemoryGameOverlay(currentGameMode: .constant(GameModes.easy))
        .environment(AppModel())
}
