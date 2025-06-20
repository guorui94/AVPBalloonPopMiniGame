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
        Text("🎮 Score: \(displayScore.score)")
            .font(.title)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    BalloonGameInterface()
        .environment(AppModel())
}
