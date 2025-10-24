import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Debug helper you can call from anywhere (e.g. the "Verify Firebase Connection" button in ContentView)
func verifyFirebasePlistAndConnection() async {
    // A) Print which Firebase project we're actually pointing at
    if let opts = FirebaseApp.app()?.options {
        print("🔍 Runtime Firebase check:")
        print("   ProjectID:", opts.projectID ?? "nil")
        print("   AppID:", opts.googleAppID)
        print("   DB URL:", opts.databaseURL ?? "nil")
    } else {
        print("⚠️ No FirebaseApp configured. (Did AppDelegate run?)")
        return
    }

    // B) Ensure we have an authenticated user (anonymous sign-in is fine)
    var user: User?
    if let current = Auth.auth().currentUser {
        user = current
    } else {
        do {
            let result = try await Auth.auth().signInAnonymously()
            user = result.user
        } catch {
            print("❌ Anonymous auth failed:", error.localizedDescription)
            return
        }
    }

    guard let u = user else {
        print("⚠️ No user after sign-in?")
        return
    }

    print("✅ Auth user uid:", u.uid)

    // We'll format a nice readable timestamp string
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let nowString = isoFormatter.string(from: Date())

    // C) Try a Firestore write to a STABLE doc:
    //    connectivity_check / status
    //    This will overwrite the same doc each time, so you can just open it
    //    in Firestore and see "ok", "when", and "uid".
    let db = Firestore.firestore()
    let statusRef = db.collection("connectivity_check").document("status")

    do {
        try await statusRef.setData([
            "ok": true,              // <- simple health flag
            "when": nowString,       // <- readable time
            "uid": u.uid,            // <- which Firebase Auth user was used
            "platform": "visionOS",  // <- bonus: identify platform
        ])
        print("✅ Wrote connectivity_check/status")
    } catch {
        print("❌ Test write failed:", error.localizedDescription)
    }

    // D) Try a read from sessions
    do {
        _ = try await db.collection("sessions")
            .limit(to: 1)
            .getDocuments()
        print("✅ Firestore read from 'sessions' succeeded.")
    } catch {
        print("❌ Firestore read from 'sessions' failed:", error.localizedDescription)
    }
}
