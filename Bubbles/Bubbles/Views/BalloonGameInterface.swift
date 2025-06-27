//
//  BalloonGameInterface.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI

struct BalloonGameInterface: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        let displayScore = appModel.score

        VStack(spacing: 8) {
            Text("Score")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.secondary)

            Text("\(displayScore.score)")
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(width: 240)
    }
}

#Preview() {
    VStack {
        Spacer()
        BalloonGameInterface()
            .environment(AppModel())
            .glassBackgroundEffect( in: RoundedRectangle(
                cornerRadius: 32,
                style: .continuous
            ))
    }
}
