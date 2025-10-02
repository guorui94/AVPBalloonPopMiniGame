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
    @State private var playerEmail: String = ""

    // --- Validation alert
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    // Email validation (UI-level)
    private var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES[c] %@", pattern)
            .evaluate(with: playerEmail)
    }
    private var isFormValid: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidEmail
    }

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 30) {
                Spacer()

                Text("🎈 Balloon Frenzy 🎈")
                    .font(.extraLargeTitle)
                    .foregroundStyle(.cyan)
                    .fontWeight(.bold)

                Text("You have 20 seconds to pop as many balloons as you can before they disappear at the top!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)

                HStack {
                    VStack(alignment: .leading) {
                        DisplayBalloonColors(color: BalloonColor.red.swiftColor,   points: BalloonColor.red.poppingScore)
                        DisplayBalloonColors(color: BalloonColor.green.swiftColor, points: BalloonColor.green.poppingScore)
                    }
                    VStack(alignment: .leading) {
                        DisplayBalloonColors(color: BalloonColor.purple.swiftColor, points: BalloonColor.purple.poppingScore)
                        DisplayBalloonColors(color: BalloonColor.gold.swiftColor,   points: BalloonColor.gold.poppingScore)
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.cyan)
                    }
                }

                Text("Balloons with higher points move faster and push other balloons.")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 700)

                Text("Balloons will start blinking when they're about to fly away — pop them quickly!")
                    .font(.title2)
                    .foregroundStyle(.cyan)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 900)
                    .padding(.bottom, 10)

                // ---------- Name + Email (above the button)
                VStack(spacing: 14) {
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
                            .frame(maxWidth: 420)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.9))
                        TextField("name@example.com", text: $playerEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(playerEmail.isEmpty ? .white.opacity(0.35)
                                           : (isValidEmail ? .cyan.opacity(0.8) : .red.opacity(0.7)),
                                            lineWidth: 1)
                            )
                            .frame(maxWidth: 430)

                        if !playerEmail.isEmpty && !isValidEmail {
                            Text("Please enter a valid email address.")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.top, -10)

                // ---------- Start Button
                Button(action: { handleStartTap() }) {
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
                            .stroke((isStarting || !isFormValid) ? Color.clear : .white, lineWidth: 2.5)
                    )
                }
                .padding(.top, 12)   // small vertical gap above the button
                .disabled(isStarting) // allow tap when invalid so we can show the alert
                .buttonStyle(.plain)
                .accessibilityHint("Enter your name and email to begin the game")

                Spacer()
            }
            Spacer()
        }
        .padding(40)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(alignment: .topLeading) {
            Button(action: { appModel.currentScreen = .menu }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 28, weight: .medium))
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .clipShape(Circle())
            .padding([.top, .leading], 20)
            .buttonStyle(.plain)
            .hoverEffect { effect, isActive, _ in
                effect.scaleEffect(!isActive ? 1.0 : 1.2)
            }
        }
        .opacity(isFadingOut ? 0 : 1)
        .animation(.easeInOut(duration: 0.5), value: isFadingOut)
        .onAppear {
            if let cached = appModel.cachedPlayerInfo {
                playerName = cached.name
                playerEmail = cached.email
            }
        }
        .onChange(of: appModel.gameEnds) { _, _ in
            resetGameState()
        }
        // Validation alert
        .alert("Incomplete Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    // Validate first; if invalid, show popup; else start.
    private func handleStartTap() {
        let nameEmpty  = playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailEmpty = playerEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if nameEmpty && emailEmpty {
            validationMessage = "Please enter your name and email."
            showValidationAlert = true
            return
        }
        if nameEmpty {
            validationMessage = "Please enter your name."
            showValidationAlert = true
            return
        }
        if emailEmpty {
            validationMessage = "Please enter your email."
            showValidationAlert = true
            return
        }
        if !isValidEmail {
            validationMessage = "Please enter a valid email (e.g., name@example.com)."
            showValidationAlert = true
            return
        }
        startCountdown()
    }

    private func startCountdown() {
        // Save into your model so it can be written to a database later
        appModel.setPlayerInfo(name: playerName, email: playerEmail)

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
            appModel.isBalloonGame = true
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
