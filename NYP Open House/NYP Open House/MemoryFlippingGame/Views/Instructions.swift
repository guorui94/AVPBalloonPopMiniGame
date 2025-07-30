//
//  Instructions.swift
//  NYP Open House
//
//  Created by Amelia on 16/7/25.
//

import SwiftUI

struct Instructions: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var isStarting = false
    @State private var countdown: Int? = nil
    @State private var isFadingOut = false
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 28) {
                Text("🧠 NYP Memory Quest")
                    .font(.extraLargeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
            
                Text("Test your memory skills by flipping tiles to match pairs of images.")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 650)
                
                VStack(alignment: .leading, spacing: 14) {
                    InstructionStep(number: 1, text: "Tap on any tile to flip it over.")
                    InstructionStep(number: 2, text: "Flip another tile to find a matching image.")
                    InstructionStep(number: 3, text: "Matched pairs will disappear from the board.")
                    InstructionStep(number: 4, text: "Complete all pairs to level up!")
                }
                
                Text("💡 Each image on the tiles represents an exciting opportunity at Nanyang Polytechnic — like Overseas Exchange, Scholarships, and more!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.mint)
                    .padding(.horizontal)
                    .frame(maxWidth: 740)
                
                Text("Can you uncover them all?")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.top, 4)
                
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
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
            .frame(maxWidth: 870)
            .overlay(alignment: .topLeading) {
                Button(action: {
                    appModel.currentScreen = .balloonIntro
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 28, weight: .medium))
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
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
        .opacity(isFadingOut ? 0 : 1)
        .animation(.easeInOut(duration: 0.5), value: isFadingOut)
    }
    private func startCountdown() {
        countdown = 3
        isStarting = true
        Task {
            for i in (1...3).reversed() {
                countdown = i
                try? await Task.sleep(for: .seconds(1))
            }
            countdown = nil

            withAnimation {
                isFadingOut = true
            }
            try? await Task.sleep(for: .seconds(0.5))

            await openImmersiveSpace(id: Module.memoryFlippingSpace.name)
            dismissWindow(id: "content")
            appModel.isMemoryGame = true
        }
    }
}


#Preview {
    Instructions()
        .environment(AppModel())
}
