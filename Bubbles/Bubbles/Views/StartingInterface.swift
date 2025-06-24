//
//  StartingInterface.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI

struct StartingInterface: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(AppModel.self) private var appModel
    @State private var isStarting = false
    @State private var isHovering = false
    @State private var changeInterface = false
    private var scoreInterface = BalloonGameInterface()
    var body: some View {
        if changeInterface {
            scoreInterface
        } else {
            VStack(spacing: 40) {
                Text("🎈 Pop Balloons 🎈")
                    .font(.extraLargeTitle)
                    .fontWeight(.semibold)

                Text(
                    "Get ready to pop as many balloons as you can before the balloon disappears!"
                )
                .font(.title2)
                .multilineTextAlignment(.center)
                .frame(width: 400)

                Button(action: {
                    isStarting = true
                    Task {
                        await openImmersiveSpace(id: appModel.immersiveSpaceID)
                        changeInterface = true
                    }
                }) {
                    Text(isStarting ? "Starting the game..." : "Start Popping!")
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

            }
            .padding(40)
        }
    }
}

#Preview(windowStyle: .automatic) {
    StartingInterface()
        .environment(AppModel())
}
