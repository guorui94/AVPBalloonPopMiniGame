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
                    VStack(spacing: 16) {
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

                        // 💡 Description — split into two lines
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

                        // --- Name + Phone fields
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
                        .padding(.top, 10)
                        .disabled(isStarting)
                        .buttonStyle(.plain)

                        // Footer note
                        VStack(spacing: 4) {
                            Text("We only use your name and phone number to save scores and contact winners.")
                            Text("Nothing is shared externally.")
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
            // Load per-game (memory) cached contact
            if let cached = appModel.cachedMemoryContact {
                playerName = cached.name
                playerPhone = cached.phone
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
        let phoneEmpty = playerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if nameEmpty && phoneEmpty { validationMessage = "Please enter your name and phone number."; showValidationAlert = true; return }
        if nameEmpty { validationMessage = "Please enter your name."; showValidationAlert = true; return }
        if phoneEmpty { validationMessage = "Please enter your phone number."; showValidationAlert = true; return }
        if !isValidPhone { validationMessage = "Please enter a valid phone number (e.g., +65 9123 4567)."; showValidationAlert = true; return }
        startCountdown()
    }

    private func startCountdown() {
        // Save per-game (memory) contact + start fresh session
        appModel.setMemoryContact(name: playerName, phone: playerPhone)
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
