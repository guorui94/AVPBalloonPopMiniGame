//
//  BalloonEndGame.swift
//  Bubbles
//
//  Created by Amelia on 1/7/25.
//

import SwiftUI

struct BalloonEndGame: View {
    @Environment(AppModel.self) private var appModel
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
                    .font(.title3)
                    .foregroundStyle(Color(white: 0.9))

                Text(verbatim: "\(String(format: "%02d", displayScore.poppingScore))")
                    .font(.system(size: 50, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.cyan)

                HStack(spacing: 20) {
                    Button(action: {
                        onPlayAgain()
                    }) {
                        Text("Play Again")
                            .padding()
                            .frame(width: 140)
                            .background(Color.cyan.opacity(0.2))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan, lineWidth: 2))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        onBackToMenu()
                    }) {
                        Text("Back to Menu")
                            .padding()
                            .frame(width: 140)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.5), lineWidth: 2))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal,50)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: .cyan.opacity(0.3), radius: 20, x: 0, y: 10)

        }
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32, style: .continuous)
        )
    }
}

#Preview {
    BalloonEndGame(onPlayAgain: {}, onBackToMenu: {})
        .environment(AppModel())
}
