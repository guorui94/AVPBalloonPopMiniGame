//
//  AppModel.swift
//  NYP Open House
//

import SwiftUI
import AVFoundation
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    enum ImmersiveSpaceState { case closed, inTransition, open }
    enum AppScreen { case menu, balloonIntro, endGame, memoryGame }

    var immersiveSpaceState: ImmersiveSpaceState = .closed
    var currentScreen: AppScreen = .menu

    var balloonPoppingsounds = [AudioFileResource]()

    init() {
        Task { @MainActor in
            do {
                for number in 1...3 {
                    let resource = try await AudioFileResource(named: "balloonpopping\(number).mp3")
                    balloonPoppingsounds.append(resource)
                }
                await pose.runArSession()
            } catch {
                fatalError("Error loading sound resources.")
            }
        }
    }

    private var balloonEndGame = try! AVAudioPlayer(
        contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!
    )
    private var applauses = try! AVAudioPlayer(
        contentsOf: Bundle.main.url(forResource: "highScoreApplause", withExtension: "mp3")!
    )

    var score = ScoreModel()
    var pose = VisionProPose()
    var currentGameMode: GameModes? = .easy

    // set game states
    var isBalloonGame = false
    var isMemoryGame = false
    var gameEnds = false

    // functions
    func resetBalloonGame() {
        score.resetBalloonScore()
        score.balloonsRemoved = 0
    }

    func resetMemoryGame() {
        score.resetMemoryGameScore()
        score.flipScore = 0
    }

    func trackBalloonsRemoved() {
        score.balloonsRemoved += 1
        if score.balloonsRemoved >= 25 {
            gameEnds = true
        }
    }

    func signalEndGame() { balloonEndGame.play() }
    func highScoreApplause() { applauses.play() }

    // ---------------------------------------------------------
    // MARK: - Player Info (no phone)
    // ---------------------------------------------------------
    struct PlayerInfo: Codable {
        var name: String
    }

    /// Legacy shape stored previously (with phone).
    private struct LegacyPlayerInfo: Codable {
        var name: String
        var phone: String
    }

    // ---------- Balloon game contact ----------
    var balloonContact: PlayerInfo? = nil

    var cachedBalloonContact: PlayerInfo? {
        if let data = UserDefaults.standard.data(forKey: "balloon_contact") {
            // Try new shape first
            if let info = try? JSONDecoder().decode(PlayerInfo.self, from: data) {
                return info
            }
            // Fallback to legacy (with phone) and map to new type
            if let legacy = try? JSONDecoder().decode(LegacyPlayerInfo.self, from: data) {
                return PlayerInfo(name: legacy.name)
            }
            // Extra safety: if someone stored as a simple dict before
            if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let name = dict["name"] as? String {
                return PlayerInfo(name: name)
            }
        }
        return nil
    }

    /// New API: set only name
    func setBalloonContact(name: String) {
        let info = PlayerInfo(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        balloonContact = info
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "balloon_contact")
        }
    }

    // ---------- Memory game contact ----------
    var memoryContact: PlayerInfo? = nil

    var cachedMemoryContact: PlayerInfo? {
        if let data = UserDefaults.standard.data(forKey: "memory_contact") {
            if let info = try? JSONDecoder().decode(PlayerInfo.self, from: data) {
                return info
            }
            if let legacy = try? JSONDecoder().decode(LegacyPlayerInfo.self, from: data) {
                return PlayerInfo(name: legacy.name)
            }
            if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let name = dict["name"] as? String {
                return PlayerInfo(name: name)
            }
        }
        return nil
    }

    /// New API: set only name
    func setMemoryContact(name: String) {
        let info = PlayerInfo(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        memoryContact = info
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "memory_contact")
        }
    }

    // ---------- Back-compat shims (old calls keep compiling) ----------
    /// Old signature kept for source compatibility (phone ignored).
    func setBalloonContact(name: String, phone: String) {
        setBalloonContact(name: name)
    }
    /// Old signature kept for source compatibility (phone ignored).
    func setMemoryContact(name: String, phone: String) {
        setMemoryContact(name: name)
    }

    /// Older generic accessors that some files may still reference:
    var playerInfo: PlayerInfo? {
        get { balloonContact }
        set { balloonContact = newValue }
    }
    var cachedPlayerInfo: PlayerInfo? { cachedBalloonContact }
    /// Old shim: `email` param existed before; now ignored.
    func setPlayerInfo(name: String, email: String) {
        setBalloonContact(name: name)
    }

    var memoryPlayerInfo: PlayerInfo? {
        get { memoryContact }
        set { memoryContact = newValue }
    }
    var cachedMemoryPlayerInfo: PlayerInfo? { cachedMemoryContact }
    /// Old shim: `email` param existed before; now ignored.
    func setMemoryPlayerInfo(name: String, email: String) {
        setMemoryContact(name: name)
    }

    // ---------------------------------------------------------
    // MARK: - Sessions (start / end / finalize)
    // ---------------------------------------------------------
    func startBalloonSession() {
        score.beginBalloonSession()
        isBalloonGame = true
        isMemoryGame = false
        gameEnds = false
    }

    func endBalloonSession() {
        score.endBalloonSession()
    }

    func startMemorySession() {
        score.beginMemorySession()
        isMemoryGame = true
        isBalloonGame = false
        gameEnds = false
    }

    func endMemorySession() {
        score.endMemorySession()
    }

    /// Call this on EndGame to capture the final score into history.
    func finalizeCurrentSession() {
        if isBalloonGame {
            endBalloonSession()
        } else if isMemoryGame {
            endMemorySession()
        }
    }
}
