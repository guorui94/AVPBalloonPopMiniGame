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

    var isBalloonGame = false
    var isMemoryGame = false
    var gameEnds = false

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

    struct PlayerInfo: Codable {
        var name: String
    }

    private struct LegacyPlayerInfo: Codable {
        var name: String
        var phone: String
    }

    var balloonContact: PlayerInfo? = nil

    var cachedBalloonContact: PlayerInfo? {
        if let data = UserDefaults.standard.data(forKey: "balloon_contact") {
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

    func setBalloonContact(name: String) {
        let info = PlayerInfo(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        balloonContact = info
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "balloon_contact")
        }
    }

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

    func setMemoryContact(name: String) {
        let info = PlayerInfo(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        memoryContact = info
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "memory_contact")
        }
    }

    func setBalloonContact(name: String, phone: String) {
        setBalloonContact(name: name)
    }
    func setMemoryContact(name: String, phone: String) {
        setMemoryContact(name: name)
    }

    var playerInfo: PlayerInfo? {
        get { balloonContact }
        set { balloonContact = newValue }
    }
    var cachedPlayerInfo: PlayerInfo? { cachedBalloonContact }
    func setPlayerInfo(name: String, email: String) {
        setBalloonContact(name: name)
    }

    var memoryPlayerInfo: PlayerInfo? {
        get { memoryContact }
        set { memoryContact = newValue }
    }
    var cachedMemoryPlayerInfo: PlayerInfo? { cachedMemoryContact }
    func setMemoryPlayerInfo(name: String, email: String) {
        setMemoryContact(name: name)
    }

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

    func finalizeCurrentSession() {
        if isBalloonGame {
            endBalloonSession()
        } else if isMemoryGame {
            endMemorySession()
        }
    }
}
