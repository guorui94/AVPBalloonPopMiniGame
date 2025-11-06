//
//  SessionService.swift
//  NYP Open House
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore writer for game sessions.
/// Usage:
///   try await SessionService.saveSession(
///       name: "...", phone: "...", gameType: "...", score: 123
///   )
enum SessionService {

    /// Saves one session document into `sessions/{sessionId}`.
    /// Will anonymously sign in the user if needed.
    static func saveSession(
        name: String,
        phone: String,
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

        // 2) Prepare the payload
        let sessionId = UUID().uuidString
        let data: [String: Any] = [
            "sessionId": sessionId,
            "uid": user.uid,
            "name": name,
            "phone": phone,
            "gameType": gameType,
            "score": score,
            "createdAt": FieldValue.serverTimestamp()
        ]

        // 3) Write to Firestore
        let db = Firestore.firestore()
        try await db.collection("sessions").document(sessionId).setData(data)

        print("📤 Saved session to Firestore at sessions/\(sessionId)")
    }
}
