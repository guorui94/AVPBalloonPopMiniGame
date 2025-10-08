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

    private var balloonEndGame = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "signalEndGame", withExtension: "mp3")!)
    private var applauses = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "highScoreApplause", withExtension: "mp3")!)

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
    // MARK: - Player Info (shared type used by BOTH games) change this part separate
    // ---------------------------------------------------------

    /// A single shared type so we can reuse everywhere.
    struct PlayerInfo: Codable {
        var name: String
        var email: String
    }

    // Balloon game info
    var playerInfo: PlayerInfo? = nil
    var cachedPlayerInfo: PlayerInfo? {
        if let data = UserDefaults.standard.data(forKey: "player_info"),
           let info = try? JSONDecoder().decode(PlayerInfo.self, from: data) {
            return info
        }
        return nil
    }
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

    // Memory game info
    var memoryPlayerInfo: PlayerInfo? = nil
    var cachedMemoryPlayerInfo: PlayerInfo? {
        if let data = UserDefaults.standard.data(forKey: "memory_player_info"),
           let info = try? JSONDecoder().decode(PlayerInfo.self, from: data) {
            return info
        }
        return nil
    }
    func setMemoryPlayerInfo(name: String, email: String) {
        let info = PlayerInfo(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        memoryPlayerInfo = info
        if let data = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(data, forKey: "memory_player_info")
        }
    }
}
