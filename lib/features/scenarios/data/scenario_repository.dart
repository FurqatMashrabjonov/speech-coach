import 'package:flutter/material.dart';
import 'package:speech_coach/features/scenarios/domain/scenario_entity.dart';

class ScenarioRepository {
  static final List<Scenario> _scenarios = [
    // --- Interviews ---
    const Scenario(
      id: 'int_1',
      category: 'Interviews',
      title: 'Tell Me About Yourself',
      description:
          'Practice the classic opening question. Craft a compelling 2-minute personal pitch.',
      durationMinutes: 2,
      difficulty: 'Easy',
      systemPrompt:
          'You are a hiring manager at a top tech company conducting a job interview. '
          'Start by warmly greeting the candidate and asking "Tell me about yourself." '
          'Listen carefully, then ask 1-2 natural follow-up questions about their background. '
          'Be professional but friendly. Evaluate how concise, structured, and engaging their answer is.',
      icon: Icons.person_outline_rounded,
    ),
    const Scenario(
      id: 'int_2',
      category: 'Interviews',
      title: 'Behavioral: Conflict Resolution',
      description:
          'Answer a behavioral question about handling workplace conflict using the STAR method.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a hiring manager conducting a behavioral interview. '
          'Ask: "Tell me about a time you had a conflict with a coworker. How did you handle it?" '
          'Listen for STAR method structure (Situation, Task, Action, Result). '
          'Ask follow-up questions to dig deeper. Be professional and evaluative.',
      icon: Icons.people_outline_rounded,
    ),
    const Scenario(
      id: 'int_3',
      category: 'Interviews',
      title: 'Technical: System Design Walkthrough',
      description:
          'Walk through a system design question. Explain your thinking process clearly.',
      durationMinutes: 5,
      difficulty: 'Hard',
      systemPrompt:
          'You are a senior engineer conducting a system design interview. '
          'Ask the candidate to design a URL shortener service (like bit.ly). '
          'Listen for their approach to requirements, high-level design, data model, and scalability. '
          'Ask clarifying questions and push them on trade-offs. Be technical but supportive.',
      icon: Icons.developer_board_rounded,
    ),
    const Scenario(
      id: 'int_4',
      category: 'Interviews',
      title: 'Salary Negotiation',
      description:
          'Practice negotiating your salary with confidence and strategy.',
      durationMinutes: 3,
      difficulty: 'Hard',
      systemPrompt:
          'You are an HR manager extending a job offer. The base salary is \$85,000. '
          'The candidate may try to negotiate higher. Be professional but firm initially, '
          'then show some flexibility. Test their negotiation skills. '
          'Ask about their expectations and reasoning.',
      icon: Icons.attach_money_rounded,
    ),
    const Scenario(
      id: 'int_5',
      category: 'Interviews',
      title: 'Why Should We Hire You?',
      description:
          'Deliver a compelling case for why you are the best candidate.',
      durationMinutes: 2,
      difficulty: 'Medium',
      systemPrompt:
          'You are a hiring manager near the end of an interview. '
          'Ask: "Why should we hire you over other candidates?" '
          'Listen for specificity, confidence, and alignment with company values. '
          'Ask one follow-up question. Be warm but evaluative.',
      icon: Icons.star_outline_rounded,
    ),

    // --- Presentations ---
    const Scenario(
      id: 'pres_1',
      category: 'Presentations',
      title: 'Elevator Pitch',
      description:
          'Pitch your idea, product, or startup in 60 seconds flat.',
      durationMinutes: 1,
      difficulty: 'Easy',
      systemPrompt:
          'You are a venture capitalist in an elevator. The speaker has 60 seconds to pitch their idea. '
          'Listen carefully, then ask 1-2 sharp follow-up questions about the market, team, or traction. '
          'Be interested but critical. Time pressure is key.',
      icon: Icons.rocket_launch_rounded,
    ),
    const Scenario(
      id: 'pres_2',
      category: 'Presentations',
      title: 'Quarterly Business Review',
      description:
          'Present Q4 results to stakeholders with clarity and confidence.',
      durationMinutes: 5,
      difficulty: 'Hard',
      systemPrompt:
          'You are a C-suite executive attending a quarterly business review. '
          'The presenter should cover results, key metrics, challenges, and next steps. '
          'Ask pointed questions about numbers, trends, and strategy. Be professional and demanding.',
      icon: Icons.bar_chart_rounded,
    ),
    const Scenario(
      id: 'pres_3',
      category: 'Presentations',
      title: 'Product Demo',
      description:
          'Demo a product feature to potential customers or stakeholders.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a potential customer evaluating a product demo. '
          'Listen for clear value proposition, use cases, and benefits. '
          'Ask questions about pricing, integration, and how it compares to competitors. '
          'Be genuinely curious but ask tough questions.',
      icon: Icons.devices_rounded,
    ),
    const Scenario(
      id: 'pres_4',
      category: 'Presentations',
      title: 'Team All-Hands Update',
      description:
          'Give a team update that is clear, motivating, and action-oriented.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are a team member at an all-hands meeting. The speaker is a team lead giving updates. '
          'Listen for clarity, team morale, and actionable next steps. '
          'Ask follow-up questions about timelines, blockers, or priorities. Be engaged and supportive.',
      icon: Icons.groups_rounded,
    ),
    const Scenario(
      id: 'pres_5',
      category: 'Presentations',
      title: 'Investor Pitch Deck',
      description:
          'Present your startup to investors — problem, solution, market, traction.',
      durationMinutes: 5,
      difficulty: 'Hard',
      systemPrompt:
          'You are a venture capitalist hearing a startup pitch. '
          'Expect to hear about problem, solution, market size, business model, traction, and ask. '
          'Ask challenging questions about competition, unit economics, and defensibility. '
          'Be respectful but rigorous.',
      icon: Icons.trending_up_rounded,
    ),

    // --- Public Speaking ---
    const Scenario(
      id: 'pub_1',
      category: 'Public Speaking',
      title: 'Wedding Toast',
      description:
          'Give a heartfelt, funny, and memorable wedding toast.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are a wedding guest listening to a toast. React naturally — laugh at jokes, '
          'show emotion at touching moments. After the toast, give brief encouraging feedback '
          'on delivery and content. Be warm and supportive.',
      icon: Icons.wine_bar_rounded,
    ),
    const Scenario(
      id: 'pub_2',
      category: 'Public Speaking',
      title: 'Acceptance Speech',
      description:
          'Accept an award with grace, gratitude, and memorable delivery.',
      durationMinutes: 2,
      difficulty: 'Easy',
      systemPrompt:
          'You are an audience member at an awards ceremony. The speaker just won an award. '
          'Listen for gratitude, humility, storytelling, and poise. '
          'React naturally and provide brief feedback afterward.',
      icon: Icons.emoji_events_rounded,
    ),
    const Scenario(
      id: 'pub_3',
      category: 'Public Speaking',
      title: 'Motivational Talk',
      description:
          'Inspire an audience with a powerful motivational message.',
      durationMinutes: 5,
      difficulty: 'Hard',
      systemPrompt:
          'You are an audience member at a motivational seminar. '
          'Listen for inspiring stories, clear message, emotional connection, and call to action. '
          'React with engagement. Ask a thoughtful question at the end.',
      icon: Icons.local_fire_department_rounded,
    ),
    const Scenario(
      id: 'pub_4',
      category: 'Public Speaking',
      title: 'TED-Style Talk',
      description:
          'Deliver a TED-style talk on a topic you are passionate about.',
      durationMinutes: 5,
      difficulty: 'Hard',
      systemPrompt:
          'You are a TED audience member. Listen for a compelling opening, '
          'clear narrative structure, surprising insights, and a memorable closing. '
          'The talk should teach something new. React naturally and ask one insightful question.',
      icon: Icons.record_voice_over_rounded,
    ),
    const Scenario(
      id: 'pub_5',
      category: 'Public Speaking',
      title: 'Commencement Address',
      description:
          'Give life advice to graduates in a moving commencement speech.',
      durationMinutes: 5,
      difficulty: 'Medium',
      systemPrompt:
          'You are a graduate at a commencement ceremony. Listen for wisdom, '
          'personal stories, humor, and an inspiring message about the future. '
          'React with enthusiasm and emotion.',
      icon: Icons.school_rounded,
    ),

    // --- Debates ---
    const Scenario(
      id: 'deb_1',
      category: 'Debates',
      title: 'Should AI Replace Teachers?',
      description:
          'Debate whether AI should replace human teachers in education.',
      durationMinutes: 5,
      difficulty: 'Hard',
      systemPrompt:
          'You are a debate opponent arguing that AI should NOT replace teachers. '
          'Present strong counterarguments about human connection, critical thinking, and mentorship. '
          'Challenge the speaker\'s points with evidence and logic. Be firm but respectful. '
          'The speaker will argue FOR AI replacing teachers.',
      icon: Icons.school_rounded,
    ),
    const Scenario(
      id: 'deb_2',
      category: 'Debates',
      title: 'Remote vs Office Work',
      description:
          'Debate the merits of remote work versus traditional office work.',
      durationMinutes: 5,
      difficulty: 'Medium',
      systemPrompt:
          'You are a debate opponent arguing FOR office work. '
          'Present arguments about collaboration, culture, mentorship, and productivity. '
          'Challenge remote work claims with data and examples. Be persuasive but fair. '
          'The speaker will argue FOR remote work.',
      icon: Icons.home_work_rounded,
    ),
    const Scenario(
      id: 'deb_3',
      category: 'Debates',
      title: 'Is Social Media Harmful?',
      description:
          'Debate whether social media does more harm than good for society.',
      durationMinutes: 5,
      difficulty: 'Medium',
      systemPrompt:
          'You are a debate opponent arguing that social media is NOT harmful. '
          'Present arguments about connectivity, democratized information, and business opportunities. '
          'Challenge claims about mental health with nuance. Be thoughtful and evidence-based. '
          'The speaker will argue that social media IS harmful.',
      icon: Icons.phone_android_rounded,
    ),
    const Scenario(
      id: 'deb_4',
      category: 'Debates',
      title: 'Universal Basic Income',
      description:
          'Debate whether governments should implement universal basic income.',
      durationMinutes: 5,
      difficulty: 'Hard',
      systemPrompt:
          'You are a debate opponent arguing AGAINST universal basic income. '
          'Present arguments about economic incentives, fiscal sustainability, and inflation. '
          'Challenge the speaker\'s points with economic reasoning. Be analytical and rigorous.',
      icon: Icons.account_balance_rounded,
    ),
    const Scenario(
      id: 'deb_5',
      category: 'Debates',
      title: 'Space Exploration Funding',
      description:
          'Debate whether governments should increase space exploration spending.',
      durationMinutes: 5,
      difficulty: 'Medium',
      systemPrompt:
          'You are a debate opponent arguing AGAINST increased space funding. '
          'Present arguments about Earth-first priorities, cost-effectiveness, and alternative uses. '
          'Challenge the speaker with practical and ethical reasoning.',
      icon: Icons.rocket_rounded,
    ),

    // --- Conversations ---
    const Scenario(
      id: 'conv_1',
      category: 'Conversations',
      title: 'Networking Event Small Talk',
      description:
          'Practice making small talk at a professional networking event.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are a professional at a networking event. Make natural small talk. '
          'Ask about their work, share about yours, find common interests. '
          'Be friendly, genuine, and keep the conversation flowing. '
          'Introduce yourself first with your name and role.',
      icon: Icons.handshake_rounded,
    ),
    const Scenario(
      id: 'conv_2',
      category: 'Conversations',
      title: 'Asking Someone on a Date',
      description:
          'Practice asking someone out in a confident but respectful way.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are someone at a coffee shop. The speaker wants to get to know you. '
          'Be friendly and open. Respond naturally to their conversation. '
          'Make it realistic — sometimes be enthusiastic, sometimes ask questions. '
          'Don\'t make it too easy but be receptive to genuine connection.',
      icon: Icons.favorite_outline_rounded,
    ),
    const Scenario(
      id: 'conv_3',
      category: 'Conversations',
      title: 'Apologizing to a Friend',
      description:
          'Practice delivering a sincere apology and making amends.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a friend who was hurt by something the speaker did (they forgot your birthday). '
          'Start a bit cold/hurt. Gradually warm up as they apologize sincerely. '
          'Test whether they take responsibility and show genuine remorse. '
          'Be realistic in your emotional responses.',
      icon: Icons.sentiment_satisfied_alt_rounded,
    ),
    const Scenario(
      id: 'conv_4',
      category: 'Conversations',
      title: 'Meeting Partner\'s Parents',
      description:
          'Navigate the nerve-wracking first meeting with your partner\'s parents.',
      durationMinutes: 3,
      difficulty: 'Hard',
      systemPrompt:
          'You are the parent of the speaker\'s partner, meeting them for the first time. '
          'Be polite but evaluative. Ask about their job, intentions, and interests. '
          'Mix warmth with subtle protectiveness. Make it feel real and slightly nerve-wracking.',
      icon: Icons.family_restroom_rounded,
    ),
    const Scenario(
      id: 'conv_5',
      category: 'Conversations',
      title: 'Giving Difficult Feedback',
      description:
          'Practice giving constructive criticism to a colleague or friend.',
      durationMinutes: 3,
      difficulty: 'Hard',
      systemPrompt:
          'You are a colleague who has been underperforming on a project. '
          'The speaker needs to give you feedback. React realistically — '
          'be a bit defensive at first, then open up. Test their communication skills.',
      icon: Icons.rate_review_rounded,
    ),

    // --- Storytelling ---
    const Scenario(
      id: 'story_1',
      category: 'Storytelling',
      title: 'Share a Childhood Memory',
      description:
          'Tell a vivid story from your childhood that shaped who you are.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are an engaged listener hearing a personal story. '
          'React naturally — laugh, show surprise, express empathy. '
          'Ask follow-up questions that encourage more detail and emotion. '
          'Be genuinely curious about their experience.',
      icon: Icons.child_care_rounded,
    ),
    const Scenario(
      id: 'story_2',
      category: 'Storytelling',
      title: 'Describe Your Proudest Moment',
      description:
          'Tell the story of your proudest achievement with passion and detail.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are an audience member eager to hear about their achievement. '
          'React with genuine enthusiasm and admiration. Ask about the challenges they faced '
          'and what made it so meaningful. Be an encouraging and engaged listener.',
      icon: Icons.emoji_events_outlined,
    ),
    const Scenario(
      id: 'story_3',
      category: 'Storytelling',
      title: 'Tell a Funny Story',
      description:
          'Share a hilarious personal story that will make your listener laugh.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a friend at a dinner party listening to a funny story. '
          'Laugh at funny parts, react with surprise, and ask for more details on the best bits. '
          'Be a great audience — your reactions should encourage better storytelling.',
      icon: Icons.mood_rounded,
    ),
    const Scenario(
      id: 'story_4',
      category: 'Storytelling',
      title: 'A Lesson Learned the Hard Way',
      description:
          'Share a story about a mistake that taught you a valuable lesson.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a mentor listening to someone share a lesson they learned. '
          'Be empathetic and thoughtful. Ask questions that help them reflect deeper. '
          'Show that you relate to their experience.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    const Scenario(
      id: 'story_5',
      category: 'Storytelling',
      title: 'A Travel Adventure',
      description:
          'Tell an exciting story from a trip or travel experience.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are a friend who loves travel. Listen with excitement to their adventure. '
          'Ask about the sights, people, food, and unexpected moments. '
          'Share brief related thoughts to keep conversation flowing. Be enthusiastic.',
      icon: Icons.flight_rounded,
    ),

    // --- Phone Anxiety ---
    const Scenario(
      id: 'phone_1',
      category: 'Phone Anxiety',
      title: 'Order Food by Phone',
      description:
          'Call a restaurant and place a takeout order confidently.',
      durationMinutes: 2,
      difficulty: 'Easy',
      systemPrompt:
          'You are a restaurant employee answering the phone. Be friendly but a little rushed — '
          'it\'s a busy night. Ask what they\'d like to order, confirm details, '
          'and give a pickup time. Occasionally ask them to repeat if they mumble.',
      icon: Icons.restaurant_rounded,
    ),
    const Scenario(
      id: 'phone_2',
      category: 'Phone Anxiety',
      title: 'Call the Doctor\'s Office',
      description:
          'Schedule or reschedule a doctor appointment over the phone.',
      durationMinutes: 2,
      difficulty: 'Easy',
      systemPrompt:
          'You are a receptionist at a doctor\'s office. Be polite and professional. '
          'Ask for their name, date of birth, reason for the visit, and preferred times. '
          'Offer a couple of available slots. If they seem nervous, be patient and reassuring.',
      icon: Icons.local_hospital_rounded,
    ),
    const Scenario(
      id: 'phone_3',
      category: 'Phone Anxiety',
      title: 'Call in Sick to Work',
      description:
          'Call your boss to let them know you can\'t come in today.',
      durationMinutes: 2,
      difficulty: 'Medium',
      systemPrompt:
          'You are a manager receiving a call from an employee. Be understanding but ask '
          'a few questions: what\'s wrong, how long they expect to be out, and whether '
          'they can hand off any urgent tasks. Don\'t be harsh, but don\'t make it too easy either.',
      icon: Icons.sick_rounded,
    ),
    const Scenario(
      id: 'phone_4',
      category: 'Phone Anxiety',
      title: 'Make a Restaurant Reservation',
      description:
          'Call a restaurant to make a dinner reservation for a group.',
      durationMinutes: 2,
      difficulty: 'Easy',
      systemPrompt:
          'You are a host at a popular restaurant. Ask for date, time, party size, '
          'and any dietary restrictions or special requests. Be friendly but mention '
          'if the requested time is unavailable and offer alternatives.',
      icon: Icons.table_restaurant_rounded,
    ),
    const Scenario(
      id: 'phone_5',
      category: 'Phone Anxiety',
      title: 'Return an Item by Phone',
      description:
          'Call customer service to return a product and get a refund.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a customer service representative. Be helpful but follow procedure: '
          'ask for the order number, reason for return, and whether they want a refund or exchange. '
          'If they don\'t have the order number, help them find it. Be professional.',
      icon: Icons.assignment_return_rounded,
    ),

    // --- Dating & Social ---
    const Scenario(
      id: 'date_1',
      category: 'Dating & Social',
      title: 'First Date Conversation',
      description:
          'Practice keeping a fun, natural conversation on a first date.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are on a first date at a coffee shop. Be interested, warm, and a little playful. '
          'Share about yourself when asked, ask thoughtful questions back, and keep the '
          'conversation flowing naturally. React genuinely — laugh at funny things, '
          'show curiosity. Don\'t be too eager or too aloof.',
      icon: Icons.coffee_rounded,
    ),
    const Scenario(
      id: 'date_2',
      category: 'Dating & Social',
      title: 'Ask Someone Out',
      description:
          'Practice building up to asking someone on a date in a natural way.',
      durationMinutes: 2,
      difficulty: 'Medium',
      systemPrompt:
          'You are someone the speaker has been chatting with at a social event. '
          'Be friendly and engaged in conversation. Respond naturally — sometimes be enthusiastic, '
          'sometimes ask questions. If they ask you out, be receptive but make them work for it a little.',
      icon: Icons.favorite_outline_rounded,
    ),
    const Scenario(
      id: 'date_3',
      category: 'Dating & Social',
      title: 'Speed Dating Round',
      description:
          'Make a great impression in a 2-minute speed dating round.',
      durationMinutes: 2,
      difficulty: 'Hard',
      systemPrompt:
          'You are a speed dating participant. You have 2 minutes to get to know each other. '
          'Be quick, engaging, and ask interesting questions. Share fun facts about yourself. '
          'Be genuine and a little flirty. Time pressure makes this exciting.',
      icon: Icons.timer_rounded,
    ),
    const Scenario(
      id: 'date_4',
      category: 'Dating & Social',
      title: 'Meeting Through Mutual Friends',
      description:
          'Practice the natural introduction when friends set you up.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are meeting the speaker because a mutual friend thought you\'d get along. '
          'Reference the mutual friend, find common ground, and be open and friendly. '
          'Share stories and ask about their interests. Keep it casual and fun.',
      icon: Icons.people_outline_rounded,
    ),
    const Scenario(
      id: 'date_5',
      category: 'Dating & Social',
      title: 'Reconnecting With an Old Friend',
      description:
          'Reach out to a friend you haven\'t talked to in a while.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are an old friend the speaker hasn\'t talked to in over a year. '
          'Be happy to hear from them but also a little surprised. Catch up naturally — '
          'share what you\'ve been up to, ask about them. Be warm but realistic.',
      icon: Icons.waving_hand_rounded,
    ),

    // --- Conflict & Boundaries ---
    const Scenario(
      id: 'conf_1',
      category: 'Conflict & Boundaries',
      title: 'Ask for a Raise',
      description:
          'Build your case and confidently ask your manager for a raise.',
      durationMinutes: 3,
      difficulty: 'Hard',
      systemPrompt:
          'You are a manager in a one-on-one meeting. The employee wants to discuss compensation. '
          'Be professional and open to listening, but don\'t immediately agree. Ask them to justify '
          'their request with specific contributions. Push back gently on vague claims. '
          'Be fair but make them earn it.',
      icon: Icons.trending_up_rounded,
    ),
    const Scenario(
      id: 'conf_2',
      category: 'Conflict & Boundaries',
      title: 'Set Boundaries with a Friend',
      description:
          'Practice saying no and setting healthy boundaries respectfully.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a close friend who keeps asking favors and not respecting boundaries. '
          'The speaker needs to set limits. React realistically — be a little hurt at first, '
          'then push back, then gradually accept. Test whether they can be firm but kind.',
      icon: Icons.shield_outlined,
    ),
    const Scenario(
      id: 'conf_3',
      category: 'Conflict & Boundaries',
      title: 'Confront a Roommate',
      description:
          'Address an issue with your roommate without making things awkward.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are a roommate who has been leaving dishes in the sink and playing loud music late. '
          'When confronted, be a bit defensive at first, then gradually acknowledge the issue. '
          'Test whether the speaker can address the problem directly but maintain the relationship.',
      icon: Icons.home_rounded,
    ),
    const Scenario(
      id: 'conf_4',
      category: 'Conflict & Boundaries',
      title: 'Say No to Extra Work',
      description:
          'Practice declining additional work when you\'re already at capacity.',
      durationMinutes: 2,
      difficulty: 'Medium',
      systemPrompt:
          'You are a colleague or manager asking the speaker to take on an additional project. '
          'Be persistent but not aggressive. Explain why it\'s important and try to convince them. '
          'Accept their boundary if they hold firm, but test their resolve.',
      icon: Icons.block_rounded,
    ),
    const Scenario(
      id: 'conf_5',
      category: 'Conflict & Boundaries',
      title: 'Handle Criticism Gracefully',
      description:
          'Practice receiving harsh feedback without getting defensive.',
      durationMinutes: 3,
      difficulty: 'Hard',
      systemPrompt:
          'You are a senior colleague giving blunt, direct feedback about the speaker\'s recent work. '
          'Some of it is fair, some is a bit harsh. Deliver it matter-of-factly. '
          'See how they respond — do they get defensive, or do they listen, ask questions, and respond maturely?',
      icon: Icons.rate_review_rounded,
    ),

    // --- Social Situations ---
    const Scenario(
      id: 'soc_1',
      category: 'Social Situations',
      title: 'Party Small Talk',
      description:
          'Navigate small talk at a party where you don\'t know many people.',
      durationMinutes: 3,
      difficulty: 'Easy',
      systemPrompt:
          'You are a stranger at a house party. The speaker approaches you to chat. '
          'Be friendly and open. Make small talk about the party, mutual connections, '
          'what you do, and common interests. Keep it light and fun.',
      icon: Icons.celebration_rounded,
    ),
    const Scenario(
      id: 'soc_2',
      category: 'Social Situations',
      title: 'Networking Introduction',
      description:
          'Introduce yourself at a professional networking event confidently.',
      durationMinutes: 2,
      difficulty: 'Medium',
      systemPrompt:
          'You are a professional at a networking event. The speaker approaches to introduce themselves. '
          'Be polished and engaged. Ask about their work, share about yours briefly, and look for '
          'synergies. Evaluate their networking skills — are they memorable, confident, and genuine?',
      icon: Icons.handshake_rounded,
    ),
    const Scenario(
      id: 'soc_3',
      category: 'Social Situations',
      title: 'Dinner Party Guest',
      description:
          'Contribute to group conversation at a dinner party.',
      durationMinutes: 3,
      difficulty: 'Medium',
      systemPrompt:
          'You are hosting a dinner party. The speaker is a guest. Bring up various topics — '
          'travel, food, current events, funny stories. See if they can contribute interesting '
          'thoughts, ask good questions, and keep the energy up. Be a gracious host.',
      icon: Icons.dinner_dining_rounded,
    ),
    const Scenario(
      id: 'soc_4',
      category: 'Social Situations',
      title: 'Chat With a Neighbor',
      description:
          'Practice friendly conversation with a neighbor you just met.',
      durationMinutes: 2,
      difficulty: 'Easy',
      systemPrompt:
          'You are a friendly neighbor who just moved in next door. You bump into the speaker '
          'while getting the mail. Chat naturally about the neighborhood, introduce yourself, '
          'and be warm and approachable. Ask about local recommendations.',
      icon: Icons.cottage_rounded,
    ),
    const Scenario(
      id: 'soc_5',
      category: 'Social Situations',
      title: 'Waiting Room Conversation',
      description:
          'Start and maintain a pleasant conversation with a stranger.',
      durationMinutes: 2,
      difficulty: 'Easy',
      systemPrompt:
          'You are a stranger sitting next to the speaker in a waiting room. '
          'If they start talking, be friendly and engage. Share a little about why you\'re there, '
          'ask casual questions. Keep it light — weather, what you\'re reading, general observations. '
          'Be naturally conversational.',
      icon: Icons.event_seat_rounded,
    ),
  ];

  List<Scenario> getAllScenarios() => _scenarios;

  List<Scenario> getByCategory(String category) =>
      _scenarios.where((s) => s.category == category).toList();

  Scenario? getById(String id) {
    try {
      return _scenarios.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> get categories =>
      _scenarios.map((s) => s.category).toSet().toList();
}
