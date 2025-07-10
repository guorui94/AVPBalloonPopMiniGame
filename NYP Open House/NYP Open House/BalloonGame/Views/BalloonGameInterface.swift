//
//  BalloonGameInterface.swift
//  NYP Open House
//
//  Created by Amelia on 20/6/25.
//

import AVFoundation
import SwiftUI

struct BalloonGameInterface: View {
    @Environment(AppModel.self) var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    @State private var progress = 1.0
    @State private var triggerColorChange = false
    @State private var isPulsing = false
    @State private var secondsRemaining = 20

    @Binding var gameEnds: Bool

    var body: some View {

        let totalTime = 20.0
        let displayScore = appModel.score

        VStack(spacing: 8) {
            Text(
                verbatim: "\(String(format: "%02d", displayScore.poppingScore))"
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
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .animation(
                    triggerColorChange
                        ? .easeInOut(duration: 1.0).repeatForever(
                            autoreverses: true)
                        : .default,
                    value: isPulsing
                )

                HStack {
                    Label(
                        "\(secondsRemaining)",
                        systemImage: "hourglass.tophalf.fill"
                    )
                    .font(.footnote)
                    .foregroundStyle(triggerColorChange ? .red : .white)
                    Text("Seconds Remaining")
                        .font(.footnote)
                        .foregroundStyle(triggerColorChange ? .red : .white)
                }

            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(width: 300)
        .padding()
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32, style: .continuous)
        )
        .onReceive(timer) { _ in
            if progress > 0.0 {
                progress -= 1 / totalTime
                if progress <= 0.0 {
                    progress = 0.0
                }

                if appModel.score.balloonsRemoved >= 25 {
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
    }
    func prepareForEndGame() {
        Task {
            await dismissImmersiveSpace()
        }
        appModel.signalEndGame()
        timer.upstream.connect().cancel()
        gameEnds = true
    }
}

#Preview() {
    BalloonGameInterface(gameEnds: .constant(false))
        .environment(AppModel())
}
