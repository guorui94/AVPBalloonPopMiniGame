import Foundation
import FirebaseFirestore

struct Session: Codable, Identifiable {
    @DocumentID var id: String?          // Firestore doc id (same as sessionId)
    var sessionId: String
    var uid: String
    var name: String
    var phone: String
    var gameType: String                 // "Balloon Frenzy", "ARcade of Memories", etc.
    var score: Int
    @ServerTimestamp var createdAt: Timestamp?
}
