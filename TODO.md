# TODO

## Cloud Functions Deployment (Requires Blaze Plan)
- [ ] Upgrade Firebase project `fitness-154e6` to Blaze plan
- [ ] Run `firebase functions:secrets:set GEMINI_API_KEY` (move API key from `.env` to Secret Manager)
- [ ] Update `functions/src/index.ts` to use `defineSecret` instead of `defineString`
- [ ] Deploy functions: `firebase deploy --only functions --project fitness-154e6`
- [ ] Deploy Firestore indexes: `firebase deploy --only firestore:indexes --project fitness-154e6`
- [ ] Verify `onSessionCreated` trigger fires in Cloud Function logs
- [ ] Verify `retryPendingFeedback` cron picks up stuck sessions
