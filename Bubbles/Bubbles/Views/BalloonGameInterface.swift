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
        VStack {
            Text("Score")
                .font(.system(size: 100))
                .foregroundStyle(.white)
            
            Text("\(displayScore.score)")
                .font(.system(size: 100))
                .foregroundStyle(.white)
        }

    }
}

#Preview(windowStyle: .automatic) {
    BalloonGameInterface()
        .environment(AppModel())
}
