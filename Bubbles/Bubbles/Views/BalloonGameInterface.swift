//
//  BalloonGameInterface.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI
import AVFoundation


struct BalloonGameInterface: View {
    @Environment(AppModel.self) var appModel
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    @State private var progress = 0.0
    @State private var triggerColorChange = false
    @State private var audioPlayer: AVAudioPlayer?

    @Binding var gameEnds: Bool

    
    var body: some View {
        let triggerTime = 15.0
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

            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(
                        triggerColorChange
                            ? Color.red : Color.white.opacity(0.7), lineWidth: 2
                    )
                    .frame(width: 305, height: 9)

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 300, height: 9)
                    .padding(.horizontal, 30)
                    .tint(triggerColorChange ? Color(hue: 0.0, saturation: 0.3, brightness: 1.0) : .cyan)

            }
            .padding(.top, 20)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(width: 300)
        .padding()
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32, style: .continuous)
        )
        .onAppear{
            if let soundURL = Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.prepareToPlay()
                } catch {
                    print("Failed to initialize player: \(error)")
                }
            }

        }
        .onReceive(timer) { _ in
            if progress < 1.0 {
                progress += 1 / totalTime
                if progress >= 1.0 {
                    progress = 1.0
                }
                if progress >= triggerTime / totalTime {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        triggerColorChange = true
                    }
                }
            } else {
                timer.upstream.connect().cancel()
                gameEnds = true
                audioPlayer?.play()
            }
        }
    }

}

#Preview() {
    BalloonGameInterface(gameEnds: .constant(false))
        .environment(AppModel())
}
