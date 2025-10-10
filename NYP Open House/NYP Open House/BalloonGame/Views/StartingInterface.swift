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

    // --- Form fields
    @State private var playerName: String = ""
    @State private var playerPhone: String = ""

    // --- Validation alert
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    // Phone validation (SG: optional +65, then 8 digits starting with 6/8/9)
    private var isValidPhone: Bool {
        let trimmed = playerPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        let compact = trimmed.replacingOccurrences(of: #"[ \-]"#, with: "", options: .regularExpression)
        let pattern = #"^(?:\+65)?(?:[689]\d{7})$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: compact)
    }

    private var isFormValid: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidPhone
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

                        // ---------- Name + Phone (above the button)
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
                                            .stroke(playerName.isEmpty ? .white.opacity(0.35) : .cyan.opacity(0.8), lineWidth: 1)
                                    )
                                    .frame(maxWidth: 520)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Phone Number")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.9))
                                TextField("+65 9123 4567", text: $playerPhone)
                                    .textContentType(.telephoneNumber)
                                    .keyboardType(.phonePad)
                                    .submitLabel(.done)
                                    .padding(12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                playerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                ? .white.opacity(0.35)
                                                : (isValidPhone ? .cyan.opacity(0.8) : .red.opacity(0.7)),
                                                lineWidth: 1
                                            )
                                    )
                                    .frame(maxWidth: 540)

                                if !playerPhone.isEmpty && !isValidPhone {
                                    Text("Please enter a valid phone number (e.g., +65 9123 4567).")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                }
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
                        .disabled(isStarting)
                        .buttonStyle(.plain)

                        // ---------- Footer note
                        VStack(spacing: 6) {
                            Text("We only use your name and phone number to save scores and contact winners.")
                            Text("Nothing is shared externally.")
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
            if let cached = appModel.cachedBalloonContact {
                playerName = cached.name
                playerPhone = cached.phone
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
        let phoneEmpty = playerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if nameEmpty && phoneEmpty { validationMessage = "Please enter your name and phone number."; showValidationAlert = true; return }
        if nameEmpty { validationMessage = "Please enter your name."; showValidationAlert = true; return }
        if phoneEmpty { validationMessage = "Please enter your phone number."; showValidationAlert = true; return }
        if !isValidPhone { validationMessage = "Please enter a valid phone number (e.g., +65 9123 4567)."; showValidationAlert = true; return }
        startCountdown()
    }

    private func startCountdown() {
        // Save contact + start a fresh session (resets score & creates session ID)
        appModel.setBalloonContact(name: playerName, phone: playerPhone)
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
