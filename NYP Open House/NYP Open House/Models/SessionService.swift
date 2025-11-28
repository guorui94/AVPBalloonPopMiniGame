//
//  SessionService.swift
//  NYP Open House
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore writer for game sessions (phone removed).
/// Usage (new):
///   try await SessionService.saveSession(
///       name: "...", gameType: "...", score: 123
///   )
enum SessionService {

    static func saveSession(
        name: String,
        gameType: String,
        score: Int
    ) async throws {

        let user: User
        if let current = Auth.auth().currentUser {
            user = current
        } else {
            let result = try await Auth.auth().signInAnonymously()
            user = result.user
        }

        let sessionId = UUID().uuidString
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "Player" : trimmedName

        let data: [String: Any] = [
            "sessionId": sessionId,
            "uid": user.uid,
            "name": finalName,
            "gameType": gameType,
            "score": score,
            "createdAt": FieldValue.serverTimestamp()
        ]

        let db = Firestore.firestore()
        try await db.collection("sessions").document(sessionId).setData(data)

        print("📤 Saved session to Firestore at sessions/\(sessionId)")
    }

    @available(*, deprecated, message: "Phone has been removed. Use the overload without `phone:`.")
    static func saveSession(
        name: String,
        phone: String,
        gameType: String,
        score: Int
    ) async throws {
        try await saveSession(name: name, gameType: gameType, score: score)
    }
}
