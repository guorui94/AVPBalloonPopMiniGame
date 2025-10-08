//
//  AppModel.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import SwiftUI
import AVFoundation
import RealityKit
import Observation   // for @Observable

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    // MARK: - App / Navigation
    enum ImmersiveSpaceState { case closed, inTransition, open }
    enum AppScreen { case menu, balloonIntro, endGame, memoryGame }

    var immersiveSpaceState: ImmersiveSpaceState = .closed
    var currentScreen: AppScreen = .menu

    // MARK: - Game Flags
    var isBalloonGame = false
    var isMemoryGame  = false
    var gameEnds      = false

    // MARK: - Audio / Assets
    var balloonPoppingsounds: [AudioFileResource] = []

    private var balloonEndGame = try! AVAudioPlayer(
        contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!
    )
    private var applauses = try! AVAudioPlayer(
        contentsOf: Bundle.main.url(forResource: "highScoreApplause", withExtension: "mp3")!
    )

    // MARK: - Models already in the project
    var score = ScoreModel()
    var pose  = VisionProPose()
    var currentGameMode: GameModes? = .easy

    // MARK: - Init
    init() {
        Task { @MainActor in
            do {
                for number in 1...3 {
                    let res = try await AudioFileResource(named: "balloonpopping\(number).mp3")
                    balloonPoppingsounds.append(res)
                }
                await pose.runArSession()
            } catch {
                // Avoid crashing; just log if assets are missing in dev builds
                print("Resource load error: \(error)")
            }
        }
    }

    // MARK: - Game helpers
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

    func signalEndGame()     { balloonEndGame.play() }
    func highScoreApplause() { applauses.play() }

    // MARK: - Balloon Player Info (used by StartingInterface)
    struct PlayerInfo: Codable {
        var name: String
        var email: String
    }

    /// Observed automatically (class is @Observable)
    var playerInfo: PlayerInfo? = nil

    /// Prefill for Balloon game (unique key)
    var cachedPlayerInfo: PlayerInfo? {
        guard
            let data = UserDefaults.standard.data(forKey: "player_info_balloon"),
            let info = try? JSONDecoder().decode(PlayerInfo.self, from: data)
        else { return nil }
        return info
    }

    func setPlayerInfo(name: String, email: String) {
        let info = PlayerInfo(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        playerInfo = info
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "player_info_balloon")
        }
    }

    // MARK: - Memory Player Info (used by Instructions)
    struct MemoryPlayerInfo: Codable {
        var name: String
        var email: String
    }

    var memoryPlayerInfo: MemoryPlayerInfo? = nil

    var cachedMemoryPlayerInfo: MemoryPlayerInfo? {
        guard
            let data = UserDefaults.standard.data(forKey: "player_info_memory"),
            let info = try? JSONDecoder().decode(MemoryPlayerInfo.self, from: data)
        else { return nil }
        return info
    }

    func setMemoryPlayerInfo(name: String, email: String) {
        let info = MemoryPlayerInfo(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        memoryPlayerInfo = info
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "player_info_memory")
        }
    }

    // MARK: - (Optional) backend hook
    /// Call this after a game starts/ends to persist to your database.
    func persistPlayerInfoToDatabaseIfNeeded() async {
        // Example:
        // if isBalloonGame, use `playerInfo`
        // if isMemoryGame,  use `memoryPlayerInfo`
        // Perform your network call here.
    }
}
