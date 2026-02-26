/// Centralized image asset paths.
///
/// All paths reference PNGs in `assets/images/`. Drop the generated
/// images there and they will be picked up by the Flutter asset bundle.
class AppImages {
  AppImages._();

  // ── Mascot ──────────────────────────────────────────────────────────
  static const mascotWelcome = 'assets/images/mascot/mascot_welcome.png';
  static const mascotAnalyze = 'assets/images/mascot/mascot_analyze.png';
  static const mascotCelebrate = 'assets/images/mascot/mascot_celebrate.png';
  static const mascotSpeak = 'assets/images/mascot/mascot_speak.png';
  static const mascotPremium = 'assets/images/mascot/mascot_premium.png';
  static const mascotEmpty = 'assets/images/mascot/mascot_empty.png';
  static const mascotError = 'assets/images/mascot/mascot_error.png';

  // ── Mascot States (Speechy) ─────────────────────────────────────────
  static const mascotHappy = 'assets/images/mascot/mascot_happy.png';
  static const mascotImpressed = 'assets/images/mascot/mascot_impressed.png';
  static const mascotEncouraging = 'assets/images/mascot/mascot_encouraging.png';
  static const mascotCoaching = 'assets/images/mascot/mascot_coaching.png';
  static const mascotThinking = 'assets/images/mascot/mascot_thinking.png';

  // ── AI Characters ───────────────────────────────────────────────────
  static const characterAlex = 'assets/images/characters/character_alex.png';
  static const characterSam = 'assets/images/characters/character_sam.png';
  static const characterMorgan = 'assets/images/characters/character_morgan.png';
  static const characterJordan = 'assets/images/characters/character_jordan.png';
  static const characterRiley = 'assets/images/characters/character_riley.png';
  static const characterKai = 'assets/images/characters/character_kai.png';
  static const characterTaylor = 'assets/images/characters/character_taylor.png';
  static const characterAvery = 'assets/images/characters/character_avery.png';

  // ── Categories ──────────────────────────────────────────────────────
  static const categoryInterviews = 'assets/images/categories/category_interviews.png';
  static const categoryPresentations = 'assets/images/categories/category_presentations.png';
  static const categoryPublicSpeaking = 'assets/images/categories/category_public_speaking.png';
  static const categoryConversations = 'assets/images/categories/category_conversations.png';
  static const categoryDebates = 'assets/images/categories/category_debates.png';
  static const categoryStorytelling = 'assets/images/categories/category_storytelling.png';
  static const categoryPhoneAnxiety = 'assets/images/categories/category_phone_anxiety.png';
  static const categoryDating = 'assets/images/categories/category_dating.png';
  static const categoryConflict = 'assets/images/categories/category_conflict.png';
  static const categorySocial = 'assets/images/categories/category_social.png';

  /// Map category name → image path for easy lookup.
  static const categoryImageMap = {
    'Interviews': categoryInterviews,
    'Presentations': categoryPresentations,
    'Public Speaking': categoryPublicSpeaking,
    'Conversations': categoryConversations,
    'Debates': categoryDebates,
    'Storytelling': categoryStorytelling,
    'Phone Anxiety': categoryPhoneAnxiety,
    'Dating & Social': categoryDating,
    'Conflict & Boundaries': categoryConflict,
    'Social Situations': categorySocial,
  };
}
