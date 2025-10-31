//
//  FirebaseVerifier.swift
//  NYP Open House
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Call this using:
///   Task { await verifyFirebasePlistAndConnection() }
func verifyFirebasePlistAndConnection() async {
    // A) Print which Firebase project we’re using
    if let opts = FirebaseApp.app()?.options {
        print("🔥 Firebase debug:")
        print("  ProjectID:", opts.projectID ?? "nil")
        print("  AppID:    ", opts.googleAppID)
        print("  DB URL:   ", opts.databaseURL ?? "nil (OK for Firestore)")
    } else {
        print("❌ No FirebaseApp configured (did AppDelegate.configure() run?).")
        return
    }

    // B) Ensure we have a Firebase Auth user (anonymous sign-in is fine)
    let user: User
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
    print("✅ Auth user uid:", user.uid)

    // C) Prepare a nice readable time (SGT) + server timestamp
    let now = Date()
    let sgtZone = TimeZone(identifier: "Asia/Singapore") ?? .current
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_SG")
    formatter.timeZone = sgtZone
    formatter.dateFormat = "EEE, d MMM yyyy • h:mm:ss a 'SGT'"
    let prettySGT = formatter.string(from: now)

    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let isoTime = isoFormatter.string(from: now)

    // D) Write to a stable Firestore doc (so you can open it easily)
    let db = Firestore.firestore()
    let statusRef = db.collection("connectivity_check").document("status")

    do {
        try await statusRef.setData([
            "ok": true,                              // simple health flag
            "uid": user.uid,                         // which Firebase Auth user
            "platform": "visionOS",                  // device info
            "when": FieldValue.serverTimestamp(),    // Firestore timestamp
            "when_iso": isoTime,                     // ISO string for logs
            "when_sgt": prettySGT                    // readable SGT time
        ], merge: true)

        print("✅ Wrote connectivity_check/status at \(prettySGT)")
    } catch {
        print("❌ Firestore write failed:", error.localizedDescription)
        suggestFixForPermissionsIfNeeded(error)
    }

    // E) Try a read from sessions to confirm read access
    do {
        _ = try await db.collection("sessions").limit(to: 1).getDocuments()
        print("✅ Firestore read from 'sessions' succeeded.")
    } catch {
        print("❌ Firestore read from 'sessions' failed:", error.localizedDescription)
        suggestFixForPermissionsIfNeeded(error)
    }
}

/// If we hit permission errors, print quick guidance.
private func suggestFixForPermissionsIfNeeded(_ error: Error) {
    let msg = error.localizedDescription.lowercased()
    if msg.contains("missing or insufficient permissions") || msg.contains("permission") {
        print("""
        🔐 Hint: Firestore security rules are blocking this request.
        For quick testing, publish these temporary rules:

          rules_version = '2';
          service cloud.firestore {
            match /databases/{database}/documents {
              match /{document=**} {
                allow read, write: if request.auth != null;
              }
            }
          }

        Then re-run the verifier.
        """)
    }
}
