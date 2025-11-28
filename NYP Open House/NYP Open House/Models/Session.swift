// Models/Session.swift
import Foundation

struct Session: Codable, Identifiable {
    var id: String?
    var sessionId: String
    var uid: String
    var name: String
    var gameType: String
    var score: Int
    var createdAt: Date?

    init(
        id: String? = nil,
        sessionId: String,
        uid: String,
        name: String,
        gameType: String,
        score: Int,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.uid = uid
        self.name = name
        self.gameType = gameType
        self.score = score
        self.createdAt = createdAt
    }
}
