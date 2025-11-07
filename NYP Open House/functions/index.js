import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * When a new session is created, mirror a public-safe record into:
 *   /leaderboards/{gameType}/scores/{sessionId}
 * Fields stored publicly never include full phone.
 */
export const onSessionCreate = functions.firestore
  .document("sessions/{sid}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const gameType = String(data.gameType || "Unknown");
    const sessionId = String(data.sessionId || context.params.sid);
    const name = String(data.name || "Player");
    const score = Number.isFinite(data.score) ? data.score : 0;

    // Mask phone: publish last 4 only
    const raw = (data.phone ?? "").toString().replace(/\D/g, "");
    const last4 = raw.slice(-4);
    const phoneMasked = last4 ? `****${last4}` : "—";

    const createdAt = admin.firestore.FieldValue.serverTimestamp();

    const publicDoc = {
      sessionId,
      name,
      score,
      createdAt,
      // public-safe phone info
      last4: last4 || null,
      phoneMasked,
      // keep game to simplify queries/debug
      gameType
    };

    const ref = db
      .collection("leaderboards")
      .doc(gameType)
      .collection("scores")
      .doc(sessionId);

    await ref.set(publicDoc, { merge: true });

    return null;
  });
