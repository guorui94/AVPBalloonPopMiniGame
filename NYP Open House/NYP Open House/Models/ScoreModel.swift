//
//  ScoreModel.swift
//  NYP Open House
//
//  Created by Amelia on 20/6/25.
//

import Foundation

@Observable
class ScoreModel {

    struct GameRun: Codable, Identifiable {
        let id: UUID
        let game: String
        let score: Int
        let startedAt: Date
        let endedAt: Date
    }

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

    private(set) var balloonSessionID: UUID?
    private var balloonSessionStart: Date?
    private(set) var balloonHistory: [GameRun] = []

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

    func beginBalloonSession() {
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

        balloonSessionID = nil
        balloonSessionStart = nil
    }

    func beginMemorySession() {
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

        memorySessionID = nil
        memorySessionStart = nil
    }

    func resetBalloonScore() {
        poppingScore = 0
        balloonsRemoved = 0
        isHighScoreBalloon = false
    }

    func resetMemoryGameScore() {
        flipScore = 0
        isHighScoreMemory = false
    }

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
