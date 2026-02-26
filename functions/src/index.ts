import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineString } from "firebase-functions/params";
import * as admin from "firebase-admin";
import { generateFeedback } from "./feedback-generator";

admin.initializeApp();

const geminiApiKey = defineString("GEMINI_API_KEY");

/**
 * Triggered when a new session document is created.
 * Waits 30 seconds to let the client finish generating feedback,
 * then checks if the session is still "pending" and generates feedback if so.
 */
export const onSessionCreated = onDocumentCreated(
  "users/{userId}/sessions/{sessionId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    if (data.feedbackStatus !== "pending") return;

    // Wait 30 seconds to let client finish first
    await new Promise((resolve) => setTimeout(resolve, 30_000));

    // Re-read the document to check if client already completed it
    const freshDoc = await snapshot.ref.get();
    if (!freshDoc.exists) return;

    const freshData = freshDoc.data();
    if (!freshData || freshData.feedbackStatus !== "pending") return;

    try {
      const feedback = await generateFeedback({
        transcript: freshData.transcript || "",
        category: freshData.category || "",
        scenarioTitle: freshData.scenarioTitle || "",
        scenarioPrompt: freshData.scenarioPrompt || "",
        apiKey: geminiApiKey.value(),
      });

      await snapshot.ref.update({
        overallScore: feedback.overallScore,
        clarity: feedback.clarity,
        confidence: feedback.confidence,
        engagement: feedback.engagement,
        relevance: feedback.relevance,
        summary: feedback.summary,
        strengths: feedback.strengths,
        improvements: feedback.improvements,
        xpEarned: feedback.xpEarned,
        feedbackStatus: "completed",
        feedbackGeneratedBy: "cloud_function",
      });

      console.log(
        `Generated feedback for session ${event.params.sessionId} (user ${event.params.userId})`
      );
    } catch (error) {
      console.error(
        `Failed to generate feedback for session ${event.params.sessionId}:`,
        error
      );
      await snapshot.ref.update({ feedbackStatus: "failed" });
    }
  }
);

/**
 * Runs every 15 minutes to retry any sessions stuck in "pending" status.
 * Picks up sessions that are at least 2 minutes old (to avoid racing with onSessionCreated).
 */
export const retryPendingFeedback = onSchedule(
  "every 15 minutes",
  async () => {
  const db = admin.firestore();
  const twoMinutesAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 2 * 60 * 1000)
  );

  const pendingSessions = await db
    .collectionGroup("sessions")
    .where("feedbackStatus", "==", "pending")
    .where("createdAt", "<=", twoMinutesAgo)
    .limit(50)
    .get();

  if (pendingSessions.empty) {
    console.log("No pending sessions to retry");
    return;
  }

  console.log(`Retrying ${pendingSessions.size} pending sessions`);

  const results = await Promise.allSettled(
    pendingSessions.docs.map(async (doc) => {
      const data = doc.data();

      try {
        const feedback = await generateFeedback({
          transcript: data.transcript || "",
          category: data.category || "",
          scenarioTitle: data.scenarioTitle || "",
          scenarioPrompt: data.scenarioPrompt || "",
          apiKey: geminiApiKey.value(),
        });

        await doc.ref.update({
          overallScore: feedback.overallScore,
          clarity: feedback.clarity,
          confidence: feedback.confidence,
          engagement: feedback.engagement,
          relevance: feedback.relevance,
          summary: feedback.summary,
          strengths: feedback.strengths,
          improvements: feedback.improvements,
          xpEarned: feedback.xpEarned,
          feedbackStatus: "completed",
          feedbackGeneratedBy: "cloud_function",
        });

        console.log(`Retried feedback for session ${doc.id}`);
      } catch (error) {
        console.error(`Failed to retry session ${doc.id}:`, error);
        await doc.ref.update({ feedbackStatus: "failed" });
      }
    })
  );

  const succeeded = results.filter((r) => r.status === "fulfilled").length;
  const failed = results.filter((r) => r.status === "rejected").length;
  console.log(
    `Retry complete: ${succeeded} succeeded, ${failed} failed`
  );
});
