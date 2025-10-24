import Foundation
import FirebaseAuth
import FirebaseFirestore

enum SessionService {
    static func saveSession(
        name: String,
        phone: String,
        gameType: String,
        score: Int
    ) async throws {

        // Ensure we have an auth user (anonymous sign-in if needed)
        let user: User
        if let current = Auth.auth().currentUser {
            user = current
        } else {
            let result = try await Auth.auth().signInAnonymously()
            user = result.user
        }

        let uid = user.uid
        let sessionId = UUID().uuidString

        let sessionData: [String: Any] = [
            "sessionId": sessionId,
            "uid": uid,
            "name": name,
            "phone": phone,
            "gameType": gameType,
            "score": score,
            "createdAt": FieldValue.serverTimestamp()
        ]

        let db = Firestore.firestore()
        try await db.collection("sessions").document(sessionId).setData(sessionData)

        print("📤 Saved in Firestore.sessions/\(sessionId)")
    }
}
