//
//  StartingInterface.swift
//  NYP Open House
//

import SwiftUI

struct StartingInterface: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var isStarting = false
    @State private var countdown: Int? = nil
    @State private var isFadingOut = false

    // --- Form field (name only)
    @State private var playerName: String = ""

    // --- Validation alert
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    private var isFormValid: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {

                        // Header
                        Text("🎈 Balloon Frenzy 🎈")
                            .font(.extraLargeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.cyan)
                            .multilineTextAlignment(.center)

                        Text("You have 20 seconds to pop as many balloons as you can before they disappear at the top!")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .frame(maxWidth: 1000)

                        // Legend
                        HStack(alignment: .top, spacing: 40) {
                            VStack(alignment: .leading, spacing: 8) {
                                DisplayBalloonColors(color: BalloonColor.red.swiftColor,   points: BalloonColor.red.poppingScore)
                                DisplayBalloonColors(color: BalloonColor.green.swiftColor, points: BalloonColor.green.poppingScore)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                DisplayBalloonColors(color: BalloonColor.purple.swiftColor, points: BalloonColor.purple.poppingScore)
                                DisplayBalloonColors(color: BalloonColor.gold.swiftColor,   points: BalloonColor.gold.poppingScore)
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.cyan)
                            }
                        }

                        Text("Balloons with higher points move faster and push other balloons.")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 900)

                        Text("Balloons will start blinking when they're about to fly away — pop them quickly!")
                            .font(.title)
                            .foregroundStyle(.cyan)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 1000)

                        // ---------- Name (above the button)
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
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
                                            .stroke(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.35) : .cyan.opacity(0.8), lineWidth: 1)
                                    )
                                    .frame(maxWidth: 520)
                            }
                        }
                        .padding(.top, 4)

                        // ---------- Start Button
                        Button(action: { handleStartTap() }) {
                            Group {
                                if let currentCount = countdown {
                                    Text("Starting in \(currentCount)...")
                                } else {
                                    Text("Let's Go!")
                                }
                            }
                            .font(.title2)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 26)
                            .frame(width: 260)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((isStarting || !isFormValid) ? Color.clear : .white, lineWidth: 2.5)
                            )
                        }
                        .padding(.top, 14)
                        .disabled(isStarting || !isFormValid)
                        .buttonStyle(.plain)

                        // ---------- Footer note
                        VStack(spacing: 6) {
                            Text("We only use your name to save scores.")
                        }
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 700)
                    }
                    .frame(maxWidth: 1100)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
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
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 8)
            }
            .padding([.top, .leading], 22)
            .buttonStyle(.plain)
            .hoverEffect { effect, isActive, _ in
                effect.scaleEffect(!isActive ? 1.0 : 1.2)
            }
        }
        .opacity(isFadingOut ? 0 : 1)
        .animation(.easeInOut(duration: 0.5), value: isFadingOut)
        .onAppear {
            // Prefill name if we have cached contact (ignore phone moving forward)
            if let cached = appModel.cachedBalloonContact {
                playerName = cached.name
            }
        }
        .onChange(of: appModel.gameEnds) { _, _ in
            resetGameState()
        }
        .alert("Incomplete Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    // Validate first; if invalid, show popup; else start.
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
        // Save contact + start a fresh session (resets score & creates session ID)
        // Pass empty string for phone to avoid touching AppModel right now.
        appModel.setBalloonContact(name: playerName, phone: "")
        appModel.startBalloonSession()

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

            await openImmersiveSpace(id: Module.bubbleSpace.name)
            dismissWindow(id: "content")
        }
    }

    private func resetGameState() {
        appModel.resetBalloonGame()
        isStarting = false
        appModel.gameEnds = false
    }
}

#Preview {
    StartingInterface()
        .environment(AppModel())
}
