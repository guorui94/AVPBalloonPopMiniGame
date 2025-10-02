//
//  AppModel.swift
//  NYP Open House
//
//  Created by Amelia on 8/7/25.
//

import SwiftUI
import AVFoundation
import RealityKit
import Observation   // <- needed for @Observable

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    enum AppScreen {
        case menu
        case balloonIntro
        case endGame
        case memoryGame
    }

    // MARK: - App State
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var currentScreen: AppScreen = .menu
    var balloonPoppingsounds = [AudioFileResource]()
    private var balloonEndGame = try! AVAudioPlayer(
        contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!
    )
    private var applauses = try! AVAudioPlayer(
        contentsOf: Bundle.main.url(forResource: "highScoreApplause", withExtension: "mp3")!
    )

    var score = ScoreModel()
    var pose = VisionProPose()
    var currentGameMode: GameModes? = .easy

    // Game state flags
    var isBalloonGame = false
    var isMemoryGame = false
    var gameEnds = false

    // MARK: - Init
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
    
    // MARK: - Game Helpers
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
    
    func signalEndGame () {
        balloonEndGame.play()
    }
    
    func highScoreApplause () {
        applauses.play()
    }

    // MARK: - Player Info  ✅ (inside AppModel)
    struct PlayerInfo: Codable {
        var name: String
        var email: String
    }

    /// Observed automatically because this is an @Observable class.
    var playerInfo: PlayerInfo? = nil

    /// Convenience to prefill fields if they played before.
    var cachedPlayerInfo: PlayerInfo? {
        if let data = UserDefaults.standard.data(forKey: "player_info"),
           let info = try? JSONDecoder().decode(PlayerInfo.self, from: data) {
            return info
        }
        return nil
    }

    /// Set + cache locally (so you can also push to your DB later).
    func setPlayerInfo(name: String, email: String) {
        let info = PlayerInfo(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        playerInfo = info

        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "player_info")
        }
    }

    /// Call this wherever you want to persist to your backend.
    func persistPlayerInfoToDatabaseIfNeeded() async {
        guard let info = playerInfo else { return }
        // TODO: integrate with Firebase/Supabase/your API.
        // Example:
        // try await database.players.insert(["name": info.name, "email": info.email])
    }
}
