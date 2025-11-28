//
//  Instructions.swift
//  NYP Open House
//

import SwiftUI

struct Instructions: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var isStarting = false
    @State private var countdown: Int? = nil
    @State private var isFadingOut = false

    @State private var playerName: String = ""

    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    private var isFormValid: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("🕹️ ARcade of Memories 🃏")
                            .font(.extraLargeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.cyan)
                            .multilineTextAlignment(.center)

                        Text("Test your memory skills by flipping tiles to match pairs of images.")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .frame(maxWidth: 900)

                        VStack(alignment: .leading, spacing: 8) {
                            InstructionStep(number: 1, text: "Tap on any tile to flip it over.")
                            InstructionStep(number: 2, text: "Flip another tile to find a matching image.")
                            InstructionStep(number: 3, text: "Matched pairs will disappear from the board.")
                            InstructionStep(number: 4, text: "Complete all pairs to level up!")
                        }
                        .frame(maxWidth: 900, alignment: .leading)

                        Text("💡 Each image on the tiles represents an exciting opportunity at Nanyang Polytechnic —\nlike Overseas Exchange, Scholarships, and more!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.mint)
                            .frame(maxWidth: 900)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Can you uncover them all?")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        VStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Name")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.9))
                                TextField("Your Name", text: $playerName)
                                    .textContentType(.name)
                                    .submitLabel(.done)
                                    .padding(12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                ? .white.opacity(0.35)
                                                : .cyan.opacity(0.8),
                                                lineWidth: 1
                                            )
                                    )
                                    .frame(maxWidth: 520)
                            }
                        }

                        Button(action: { handleStartTap() }) {
                            Group {
                                if let currentCount = countdown {
                                    Text("Starting in \(currentCount)...")
                                } else {
                                    Text("Let's Go!")
                                }
                            }
                            .font(.title2)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 22)
                            .frame(width: 260)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((isStarting || !isFormValid) ? Color.clear : .white, lineWidth: 2.5)
                            )
                        }
                        .padding(.top, 10)
                        .disabled(isStarting || !isFormValid)
                        .buttonStyle(.plain)

                        VStack(spacing: 4) {
                            Text("We only use your name to save scores.")
                        }
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 700)
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: 1100)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .padding(.bottom, 8)
                    .frame(minHeight: geo.size.height, alignment: .center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(alignment: .topLeading) {
            Button(action: { appModel.currentScreen = .menu }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 28, weight: .medium))
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .padding([.top, .leading], 18)
            .buttonStyle(.plain)
            .hoverEffect { effect, isActive, _ in
                effect.scaleEffect(!isActive ? 1.0 : 1.2)
            }
        }
        .onAppear {
            if let cached = appModel.cachedMemoryContact {
                playerName = cached.name
            }
        }
        .alert("Incomplete Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    private func handleStartTap() {
        let nameEmpty  = playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if nameEmpty {
            validationMessage = "Please enter your name."
            showValidationAlert = true
            return
        }
        startCountdown()
    }

    private func startCountdown() {
        appModel.setMemoryContact(name: playerName, phone: "")
        appModel.startMemorySession()

        countdown = 3
        isStarting = true
        Task {
            for i in (1...3).reversed() {
                countdown = i
                try? await Task.sleep(for: .seconds(1))
            }
            countdown = nil

            withAnimation { isFadingOut = true }
            try? await Task.sleep(for: .seconds(0.5))

            await openImmersiveSpace(id: Module.memorySpace.name)
            dismissWindow(id: "content")
        }
    }
}

#Preview {
    Instructions()
        .environment(AppModel())
}
