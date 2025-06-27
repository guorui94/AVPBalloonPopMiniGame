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
    @State private var changeInterface = false

    var body: some View {
        // Main view UI before game starts
        ZStack {
            if !changeInterface {
                HStack {
                    Spacer()
                    VStack(spacing: 40) {
                        Spacer()
                        Text("🎈 Pop Balloons 🎈")
                            .font(.extraLargeTitle)
                            .fontWeight(.semibold)

                        Text("Get ready to pop as many balloons as you can before the balloon disappears!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(width: 400)

                        Button(action: {
                            isStarting = true
                            Task {
                                await openImmersiveSpace(id: appModel.immersiveSpaceID)
                                changeInterface = true // 🔹 show the overlay interface
                            }
                        }) {
                            Text(isStarting ? "Starting the game..." : "Start Popping!")
                                .padding()
                                .frame(width: 200)
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isStarting ? Color.clear : .white, lineWidth: 2.5)
                                )
                        }
                        .disabled(isStarting)
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(40)
                .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
        }
        .overlay(alignment:.bottomLeading) {
            if changeInterface {
                BalloonGameInterface()
                    .frame(width: 300)
                    .padding()
                    .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .offset(x: -300, y: -50)
            }
        }
        
    }
}

#Preview {
    StartingInterface()
        .environment(AppModel())
}
