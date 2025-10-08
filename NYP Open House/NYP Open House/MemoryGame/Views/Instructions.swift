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

    // --- Form fields (memory game)
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
        ZStack {
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) { // tighter overall spacing
                        // Title
                        Text("🕹️ ARcade of Memories 🃏")
                            .font(.extraLargeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.cyan)
                            .multilineTextAlignment(.center)

                        // Subtitle
                        Text("Test your memory skills by flipping tiles to match pairs of images.")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .frame(maxWidth: 900)

                        // Steps
                        VStack(alignment: .leading, spacing: 8) {
                            InstructionStep(number: 1, text: "Tap on any tile to flip it over.")
                            InstructionStep(number: 2, text: "Flip another tile to find a matching image.")
                            InstructionStep(number: 3, text: "Matched pairs will disappear from the board.")
                            InstructionStep(number: 4, text: "Complete all pairs to level up!")
                        }
                        .frame(maxWidth: 900, alignment: .leading)

                        // 💡 Description — reduced top/bottom padding
                        Text("💡 Each image on the tiles represents an exciting opportunity at Nanyang Polytechnic — like Overseas Exchange, Scholarships, and more!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.mint)
                            .frame(maxWidth: 900)
                            .padding(.vertical, 2) // <— minimal vertical padding

                        Text("Can you uncover them all?")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        // --- Name + Email fields
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
                                            .stroke(playerName.isEmpty ? .white.opacity(0.35) : .cyan.opacity(0.8), lineWidth: 1)
                                    )
                                    .frame(maxWidth: 520)
                            }

                            VStack(alignment: .leading, spacing: 4) {
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
                                            .stroke(
                                                playerEmail.isEmpty ? .white.opacity(0.35)
                                                : (isValidEmail ? .cyan.opacity(0.8) : .red.opacity(0.7)),
                                                lineWidth: 1
                                            )
                                    )
                                    .frame(maxWidth: 540)

                                if !playerEmail.isEmpty && !isValidEmail {
                                    Text("Please enter a valid email address.")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                }
                            }
                        }

                        // --- Start Button (same style as Balloon)
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
                        .padding(.top, 10) // smaller gap above button
                        .disabled(isStarting)
                        .buttonStyle(.plain)

                        // Footer note (small & always visible)
                        VStack(spacing: 4) {
                            Text("We only use your name and email to save scores and contact winners.")
                            Text("Nothing is shared externally.")
                        }
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 700)
                        .padding(.top, 10) // small space above footer
                    }
                    .frame(maxWidth: 1100)
                    .padding(.horizontal, 18) // reduced horizontal padding
                    .padding(.vertical, 6)    // reduced vertical padding
                    .padding(.bottom, 8)      // small bottom inset so footer clears the glass edge
                    // Center within the live window size
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
            if let cached = appModel.cachedMemoryPlayerInfo {
                playerName = cached.name
                playerEmail = cached.email
            }
        }
        .alert("Incomplete Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    // MARK: - Actions
    private func handleStartTap() {
        let nameEmpty  = playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailEmpty = playerEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if nameEmpty && emailEmpty { validationMessage = "Please enter your name and email."; showValidationAlert = true; return }
        if nameEmpty { validationMessage = "Please enter your name."; showValidationAlert = true; return }
        if emailEmpty { validationMessage = "Please enter your email."; showValidationAlert = true; return }
        if !isValidEmail { validationMessage = "Please enter a valid email (e.g., name@example.com)."; showValidationAlert = true; return }
        startCountdown()
    }

    private func startCountdown() {
        appModel.setMemoryPlayerInfo(name: playerName, email: playerEmail)

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
            appModel.isMemoryGame = true
        }
    }
}

#Preview {
    Instructions()
        .environment(AppModel())
}
