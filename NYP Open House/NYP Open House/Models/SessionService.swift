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

    /// New API: no phone field.
    static func saveSession(
        name: String,
        gameType: String,
        score: Int
    ) async throws {

        // 1) Ensure an authenticated user (anonymous is fine)
        let user: User
        if let current = Auth.auth().currentUser {
            user = current
        } else {
            let result = try await Auth.auth().signInAnonymously()
            user = result.user
        }

        // 2) Prepare the payload (no phone)
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

        // 3) Write to Firestore
        let db = Firestore.firestore()
        try await db.collection("sessions").document(sessionId).setData(data)

        print("📤 Saved session to Firestore at sessions/\(sessionId)")
    }

    /// Backward-compat shim so existing call sites that still pass `phone:` keep compiling.
    /// This simply ignores the phone and forwards to the new API.
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
