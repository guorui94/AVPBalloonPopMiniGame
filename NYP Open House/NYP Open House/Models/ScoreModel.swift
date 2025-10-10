//
//  ScoreModel.swift
//  NYP Open House
//
//  Created by Amelia on 20/6/25.
//

import Foundation

@Observable
class ScoreModel {

    // MARK: - Game Run record
    struct GameRun: Codable, Identifiable {
        let id: UUID
        let game: String         // "balloon" or "memory"
        let score: Int
        let startedAt: Date
        let endedAt: Date
    }

    // ----------------------------
    // Balloon Frenzy
    // ----------------------------
    var poppingScore: Int = 0 {
        didSet {
            if poppingScore > balloonHighScore {
                balloonHighScore = poppingScore
                saveBalloonHighScore()
                isHighScoreBalloon = true
            }
        }
    }
    var balloonsRemoved: Int = 0

    private(set) var balloonHighScore: Int = UserDefaults.standard.integer(forKey: "BalloonHighScore")
    var isHighScoreBalloon: Bool = false

    // Session
    private(set) var balloonSessionID: UUID?
    private var balloonSessionStart: Date?
    private(set) var balloonHistory: [GameRun] = []

    // ----------------------------
    // ARcade of Memories
    // ----------------------------
    var flipScore: Int = 0 {
        didSet {
            if flipScore > memoryGameHighScore {
                memoryGameHighScore = flipScore
                saveMemoryGameHighScore()
                isHighScoreMemory = true
            }
        }
    }

    private(set) var memoryGameHighScore: Int = UserDefaults.standard.integer(forKey: "MemoryGameHighScore")
    var isHighScoreMemory: Bool = false

    // Session
    private(set) var memorySessionID: UUID?
    private var memorySessionStart: Date?
    private(set) var memoryHistory: [GameRun] = []

    // ----------------------------
    // Init: load histories (optional)
    // ----------------------------
    init() {
        if let data = UserDefaults.standard.data(forKey: "BalloonHistory"),
           let decoded = try? JSONDecoder().decode([GameRun].self, from: data) {
            balloonHistory = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "MemoryHistory"),
           let decoded = try? JSONDecoder().decode([GameRun].self, from: data) {
            memoryHistory = decoded
        }
    }

    // ----------------------------
    // Begin / End Sessions
    // ----------------------------
    func beginBalloonSession() {
        // Reset only Balloon state for a clean run
        poppingScore = 0
        balloonsRemoved = 0
        isHighScoreBalloon = false

        balloonSessionID = UUID()
        balloonSessionStart = Date()
    }

    func endBalloonSession() {
        guard let id = balloonSessionID,
              let started = balloonSessionStart
        else { return }

        let run = GameRun(
            id: id,
            game: "balloon",
            score: poppingScore,
            startedAt: started,
            endedAt: Date()
        )
        balloonHistory.append(run)
        persistBalloonHistory()

        // Clear current session markers (optional)
        balloonSessionID = nil
        balloonSessionStart = nil
    }

    func beginMemorySession() {
        // Reset only Memory state for a clean run
        flipScore = 0
        isHighScoreMemory = false

        memorySessionID = UUID()
        memorySessionStart = Date()
    }

    func endMemorySession() {
        guard let id = memorySessionID,
              let started = memorySessionStart
        else { return }

        let run = GameRun(
            id: id,
            game: "memory",
            score: flipScore,
            startedAt: started,
            endedAt: Date()
        )
        memoryHistory.append(run)
        persistMemoryHistory()

        // Clear current session markers (optional)
        memorySessionID = nil
        memorySessionStart = nil
    }

    // ----------------------------
    // Resets (manual, if needed elsewhere)
    // ----------------------------
    func resetBalloonScore() {
        poppingScore = 0
        balloonsRemoved = 0
        isHighScoreBalloon = false
    }

    func resetMemoryGameScore() {
        flipScore = 0
        isHighScoreMemory = false
    }

    // ----------------------------
    // Persistence
    // ----------------------------
    private func saveBalloonHighScore() {
        UserDefaults.standard.set(balloonHighScore, forKey: "BalloonHighScore")
    }

    private func saveMemoryGameHighScore() {
        UserDefaults.standard.set(memoryGameHighScore, forKey: "MemoryGameHighScore")
    }

    private func persistBalloonHistory() {
        if let data = try? JSONEncoder().encode(balloonHistory) {
            UserDefaults.standard.set(data, forKey: "BalloonHistory")
        }
    }

    private func persistMemoryHistory() {
        if let data = try? JSONEncoder().encode(memoryHistory) {
            UserDefaults.standard.set(data, forKey: "MemoryHistory")
        }
    }
}
