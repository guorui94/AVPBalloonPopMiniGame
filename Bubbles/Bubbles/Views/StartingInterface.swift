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
    var body: some View {
            VStack(spacing: 40) {
                Text("🎈 Pop Balloons 🎈")
                    .font(.extraLargeTitle)
                    .fontWeight(.semibold)

                Text("Get ready to pop as many balloons as you can before the balloon disappears!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(width: 400)

                Button(action: {
                    isStarting = true
                    Task {
                        await openImmersiveSpace(id: appModel.immersiveSpaceID)
                    }
                }) {
                    Text(isStarting ? "Starting the game..." : "Start Popping!")
                        .padding()
                        .frame(width: 200)
                        .background(isStarting ? .gray : .blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isStarting)
                .buttonStyle(.plain)
                .hoverEffect()

                BalloonGameInterface()
            }
            .padding(40)
        }
}

#Preview (windowStyle: .automatic){
    StartingInterface()
        .environment(AppModel())
}
