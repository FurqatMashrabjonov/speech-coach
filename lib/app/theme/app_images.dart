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
  static const characterLuna = 'assets/images/characters/character_luna.png';
  static const characterViktor = 'assets/images/characters/character_viktor.png';
  static const characterPriya = 'assets/images/characters/character_priya.png';
  static const characterSage = 'assets/images/characters/character_sage.png';
  static const characterNadia = 'assets/images/characters/character_nadia.png';
  static const characterSunny = 'assets/images/characters/character_sunny.png';
  static const characterDev = 'assets/images/characters/character_dev.png';
  static const characterRio = 'assets/images/characters/character_rio.png';
  static const characterEthan = 'assets/images/characters/character_ethan.png';
  static const characterOmar = 'assets/images/characters/character_omar.png';
  static const characterRex = 'assets/images/characters/character_rex.png';
  static const characterIris = 'assets/images/characters/character_iris.png';
  static const characterJake = 'assets/images/characters/character_jake.png';
  static const characterDrNash = 'assets/images/characters/character_dr_nash.png';
  static const characterMarcus = 'assets/images/characters/character_marcus.png';
  static const characterZoe = 'assets/images/characters/character_zoe.png';
  static const characterMaya = 'assets/images/characters/character_maya.png';
  static const characterLeo = 'assets/images/characters/character_leo.png';
  static const characterElena = 'assets/images/characters/character_elena.png';
  static const characterProfChen = 'assets/images/characters/character_prof_chen.png';
  static const characterAria = 'assets/images/characters/character_aria.png';
  static const characterGrace = 'assets/images/characters/character_grace.png';

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

  // ── Scenarios ────────────────────────────────────────────────────────
  // Interviews
  static const scenarioInt1 = 'assets/images/scenarios/scenario_int_1.png';
  static const scenarioInt2 = 'assets/images/scenarios/scenario_int_2.png';
  static const scenarioInt3 = 'assets/images/scenarios/scenario_int_3.png';
  static const scenarioInt4 = 'assets/images/scenarios/scenario_int_4.png';
  static const scenarioInt5 = 'assets/images/scenarios/scenario_int_5.png';
  // Presentations
  static const scenarioPres1 = 'assets/images/scenarios/scenario_pres_1.png';
  static const scenarioPres2 = 'assets/images/scenarios/scenario_pres_2.png';
  static const scenarioPres3 = 'assets/images/scenarios/scenario_pres_3.png';
  static const scenarioPres4 = 'assets/images/scenarios/scenario_pres_4.png';
  static const scenarioPres5 = 'assets/images/scenarios/scenario_pres_5.png';
  // Public Speaking
  static const scenarioPub1 = 'assets/images/scenarios/scenario_pub_1.png';
  static const scenarioPub2 = 'assets/images/scenarios/scenario_pub_2.png';
  static const scenarioPub3 = 'assets/images/scenarios/scenario_pub_3.png';
  static const scenarioPub4 = 'assets/images/scenarios/scenario_pub_4.png';
  static const scenarioPub5 = 'assets/images/scenarios/scenario_pub_5.png';
  // Debates
  static const scenarioDeb1 = 'assets/images/scenarios/scenario_deb_1.png';
  static const scenarioDeb2 = 'assets/images/scenarios/scenario_deb_2.png';
  static const scenarioDeb3 = 'assets/images/scenarios/scenario_deb_3.png';
  static const scenarioDeb4 = 'assets/images/scenarios/scenario_deb_4.png';
  static const scenarioDeb5 = 'assets/images/scenarios/scenario_deb_5.png';
  // Conversations
  static const scenarioConv1 = 'assets/images/scenarios/scenario_conv_1.png';
  static const scenarioConv2 = 'assets/images/scenarios/scenario_conv_2.png';
  static const scenarioConv3 = 'assets/images/scenarios/scenario_conv_3.png';
  static const scenarioConv4 = 'assets/images/scenarios/scenario_conv_4.png';
  static const scenarioConv5 = 'assets/images/scenarios/scenario_conv_5.png';
  // Storytelling
  static const scenarioStory1 = 'assets/images/scenarios/scenario_story_1.png';
  static const scenarioStory2 = 'assets/images/scenarios/scenario_story_2.png';
  static const scenarioStory3 = 'assets/images/scenarios/scenario_story_3.png';
  static const scenarioStory4 = 'assets/images/scenarios/scenario_story_4.png';
  static const scenarioStory5 = 'assets/images/scenarios/scenario_story_5.png';
  // Phone Anxiety
  static const scenarioPhone1 = 'assets/images/scenarios/scenario_phone_1.png';
  static const scenarioPhone2 = 'assets/images/scenarios/scenario_phone_2.png';
  static const scenarioPhone3 = 'assets/images/scenarios/scenario_phone_3.png';
  static const scenarioPhone4 = 'assets/images/scenarios/scenario_phone_4.png';
  static const scenarioPhone5 = 'assets/images/scenarios/scenario_phone_5.png';
  // Dating & Social
  static const scenarioDate1 = 'assets/images/scenarios/scenario_date_1.png';
  static const scenarioDate2 = 'assets/images/scenarios/scenario_date_2.png';
  static const scenarioDate3 = 'assets/images/scenarios/scenario_date_3.png';
  static const scenarioDate4 = 'assets/images/scenarios/scenario_date_4.png';
  static const scenarioDate5 = 'assets/images/scenarios/scenario_date_5.png';
  // Conflict & Boundaries
  static const scenarioConf1 = 'assets/images/scenarios/scenario_conf_1.png';
  static const scenarioConf2 = 'assets/images/scenarios/scenario_conf_2.png';
  static const scenarioConf3 = 'assets/images/scenarios/scenario_conf_3.png';
  static const scenarioConf4 = 'assets/images/scenarios/scenario_conf_4.png';
  static const scenarioConf5 = 'assets/images/scenarios/scenario_conf_5.png';
  // Social Situations
  static const scenarioSoc1 = 'assets/images/scenarios/scenario_soc_1.png';
  static const scenarioSoc2 = 'assets/images/scenarios/scenario_soc_2.png';
  static const scenarioSoc3 = 'assets/images/scenarios/scenario_soc_3.png';
  static const scenarioSoc4 = 'assets/images/scenarios/scenario_soc_4.png';
  static const scenarioSoc5 = 'assets/images/scenarios/scenario_soc_5.png';

  /// Map scenario ID → image path for easy lookup.
  static const scenarioImageMap = {
    'int_1': scenarioInt1, 'int_2': scenarioInt2, 'int_3': scenarioInt3, 'int_4': scenarioInt4, 'int_5': scenarioInt5,
    'pres_1': scenarioPres1, 'pres_2': scenarioPres2, 'pres_3': scenarioPres3, 'pres_4': scenarioPres4, 'pres_5': scenarioPres5,
    'pub_1': scenarioPub1, 'pub_2': scenarioPub2, 'pub_3': scenarioPub3, 'pub_4': scenarioPub4, 'pub_5': scenarioPub5,
    'deb_1': scenarioDeb1, 'deb_2': scenarioDeb2, 'deb_3': scenarioDeb3, 'deb_4': scenarioDeb4, 'deb_5': scenarioDeb5,
    'conv_1': scenarioConv1, 'conv_2': scenarioConv2, 'conv_3': scenarioConv3, 'conv_4': scenarioConv4, 'conv_5': scenarioConv5,
    'story_1': scenarioStory1, 'story_2': scenarioStory2, 'story_3': scenarioStory3, 'story_4': scenarioStory4, 'story_5': scenarioStory5,
    'phone_1': scenarioPhone1, 'phone_2': scenarioPhone2, 'phone_3': scenarioPhone3, 'phone_4': scenarioPhone4, 'phone_5': scenarioPhone5,
    'date_1': scenarioDate1, 'date_2': scenarioDate2, 'date_3': scenarioDate3, 'date_4': scenarioDate4, 'date_5': scenarioDate5,
    'conf_1': scenarioConf1, 'conf_2': scenarioConf2, 'conf_3': scenarioConf3, 'conf_4': scenarioConf4, 'conf_5': scenarioConf5,
    'soc_1': scenarioSoc1, 'soc_2': scenarioSoc2, 'soc_3': scenarioSoc3, 'soc_4': scenarioSoc4, 'soc_5': scenarioSoc5,
  };
}
