// Models/Session.swift
import Foundation

/// Plain model we write/read to Firestore. No FirebaseFirestoreSwift wrappers,
/// so this compiles even if that module isn't available on visionOS.
struct Session: Codable, Identifiable {
    var id: String?          // we set this to the Firestore document id (sessionId)
    var sessionId: String
    var uid: String
    var name: String
    var phone: String
    var gameType: String     // e.g. "Balloon Frenzy" or "ARcade of Memories"
    var score: Int
    var createdAt: Date?     // Firestore server timestamp; we write it as FieldValue.serverTimestamp()

    init(
        id: String? = nil,
        sessionId: String,
        uid: String,
        name: String,
        phone: String,
        gameType: String,
        score: Int,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.uid = uid
        self.name = name
        self.phone = phone
        self.gameType = gameType
        self.score = score
        self.createdAt = createdAt
    }
}
