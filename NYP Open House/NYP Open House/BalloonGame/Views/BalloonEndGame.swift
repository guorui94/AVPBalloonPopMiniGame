//
//  BalloonEndGame.swift
//  NYP Open House
//
//  Created by Amelia on 1/7/25.
//

import SwiftUI

struct BalloonEndGame: View {
    @Environment(AppModel.self) private var appModel
    @State private var pulse = false
    var onPlayAgain: () -> Void
    var onBackToMenu: () -> Void
    var body: some View {
        let displayScore = appModel.score
        HStack {
            VStack(spacing: 30) {
                Text("MISSION COMPLETE!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.cyan, lineWidth: 2)
                            .blur(radius: 4)
                            .opacity(0.8)
                    )
                    .padding(.top, 50)

                Text("Your results are in...")
                    .font(.title)
                    .foregroundStyle(Color(white: 0.9))

                Text(verbatim: "\(String(format: "%02d", displayScore.poppingScore))")
                    .font(.system(size: 50, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.cyan)
                
                if appModel.score.isHighScore {
                    Text("New high score!!")
                        .font(.system(size: 30, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.cyan)
                        .shadow(color: .cyan.opacity(0.7), radius: 10)
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
                        .onAppear {
                            pulse = true
                        }
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        onPlayAgain()
                    }) {
                        Text("Play Again")
                            .padding()
                            .frame(width: 140)
                            .background(Color.cyan.opacity(0.2))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan, lineWidth: 2))
                    }
                    .cornerRadius(12)
                    .buttonStyle(.plain)

                    Button(action: {
                        onBackToMenu()
                    }) {
                        Text("Back to Menu")
                            .padding()
                            .frame(width: 140)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.7), lineWidth: 2))
                    }
                    .cornerRadius(12)
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 50)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: .cyan.opacity(0.3), radius: 20, x: 0, y: 10)

        }
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32, style: .continuous)
        )
        .onAppear {
            if appModel.score.isHighScore {
                appModel.highScoreApplause()
            }
        }
    }
}

#Preview {
    BalloonEndGame(onPlayAgain: {}, onBackToMenu: {})
        .environment(AppModel())
}
