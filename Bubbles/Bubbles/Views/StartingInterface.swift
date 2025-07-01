//
//  StartingInterface.swift
//  Bubbles
//
//  Created by Amelia on 20/6/25.
//

import SwiftUI

struct StartingInterface: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(AppModel.self) private var appModel
    @State private var changeInterface = false
    @State private var isStarting = false
    @State var countdown: Int? = nil
    var onBack: () -> Void  // this sets the selected interface as nil (aka go back to ContentView)

    var body: some View {
        ZStack {
            if !changeInterface {
                HStack {
                    Spacer()
                    VStack(spacing: 40) {
                        Spacer()
                        Text("🎈 Pop Balloons 🎈")
                            .font(.extraLargeTitle)
                            .fontWeight(.bold)

                        Text(
                            "Get ready to pop as many balloons as you can before the balloon disappears!"
                        )
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .frame(width: 400)

                        Button(action: {
                            startCountdown()
                        }) {
                            Group {
                                if let currentCount = countdown {
                                    Text("Starting in \(currentCount)...")
                                } else {
                                    Text("Let's Go!")
                                }
                            }
                            .font(.title)
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

                        Spacer()
                    }
                    Spacer()
                }
                .padding(40)
                .glassBackgroundEffect(
                    in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                onBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .clipShape(Circle())
            .padding([.top, .leading], 20)
            .buttonStyle(.plain)
            .hoverEffect { effect, isActive, proxy in
                effect.scaleEffect(!isActive ? 1.0 : 1.2)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if changeInterface {
                ZStack(alignment: .topLeading) {
                    BalloonGameInterface()
                    Button(action: {
                        Task {
                            await dismissImmersiveSpace()
                        }
                        changeInterface = false
                        isStarting = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .medium))
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .clipShape(Circle())
                    .padding([.top, .leading], 20)
                    .buttonStyle(.plain)
                    .hoverEffect { effect, isActive, proxy in
                        effect.scaleEffect(!isActive ? 1.0 : 1.2)
                    }
                }
                .offset(x: -250, y: -50)
            }
        }

    }
    private func startCountdown() {
        countdown = 3
        isStarting = true
        Task {
            for i in (1...3).reversed() {
                countdown = i
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            countdown = nil

            await openImmersiveSpace(id: appModel.immersiveSpaceID)
            changeInterface = true
        }

    }
}

#Preview {
    StartingInterface(onBack: {})
        .environment(AppModel())
}
