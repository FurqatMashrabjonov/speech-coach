# MVP Polish & Critical Fixes Plan

## Analysis Summary

Hozirgi holatda appda 22 ta feature directory, 27 ta route, 50 ta scenario bor. MVP uchun eng muhim 3 ta muammo:

1. **English-only enforcement** — Hech bir promptda til cheklovi yo'q. Gemini istalgan tilda javob berishi mumkin.
2. **Scenario prompt sifati** — Public Speaking kategoriyasi (5 ta) deyarli foydasiz (AI faqat tinglaydi), ba'zi promptlarda placeholder buglar bor.
3. **Vaqt muammolari** — 6 ta scenarioda vaqt juda kam (2 min debate, 2 min date asking, etc.)

---

## Phase 1: English-Only Enforcement (CRITICAL)

**Muammo:** 50 ta scenariodan HECH BIRIDA "English only" qoidasi yo'q. Agar user o'zbek/rus/arab tilida gapirsa, Gemini o'sha tilda javob beradi. Scoring ham buziladi.

### 1a. Voice conversation — guardrails ga qo'shish
**File:** `lib/features/conversation/data/gemini_live_service.dart`

`_guardrails` constantiga qo'shish:
```
- You MUST respond ONLY in English at all times, regardless of what language the user speaks.
- If the user speaks in a non-English language, gently say something like "Let's keep practicing in English! Go ahead and try again in English."
- Never switch to another language, even if the user asks you to.
```

### 1b. Text chat — same enforcement
**File:** `lib/features/text_chat/presentation/providers/text_chat_provider.dart`

`startChat()` methodidagi `fullInstruction` ga qo'shish (line ~164):
Same English-only rule appended to the text chat instruction.

### 1c. Feedback service — English expectation
**File:** `lib/features/feedback/data/feedback_service.dart`

Scoring prompt ga qo'shish:
```
Note: This conversation should have been conducted in English. If the transcript contains non-English text, note this in the summary and score accordingly — the user should be practicing English.
```

**Files changed: 3 | Lines changed: ~15**

---

## Phase 2: Fix Scenario Durations (6 scenarios)

**File:** `lib/features/scenarios/data/scenario_repository.dart`

| ID | Title | Current | New | Sabab |
|----|-------|---------|-----|-------|
| `int_1` | Tell Me About Yourself | 2 min | 3 min | Greeting + pitch + 2 follow-ups 2 minutga sig'maydi |
| `int_5` | Why Should We Hire You? | 2 min | 3 min | Main answer + "first 90 days" follow-up uchun ko'proq vaqt kerak |
| `date_2` | Ask Someone Out | 2 min | 3 min | Prompt "don't jump to the ask" deydi lekin 2 min beradi — contradiction |
| `soc_2` | Networking Introduction | 2 min | 3 min | 4-phase exchange (intro, probe, exchange, synergy) uchun kam |
| `conf_4` | Say No to Extra Work | 2 min | 3 min | 4-stage emotional arc 2 minutga sig'maydi |
| `phone_3` | Call in Sick to Work | 2 min | 3 min | Boss ning concern + practical questions uchun ko'proq vaqt |

**Files changed: 1 | Lines changed: 6 (just durationMinutes values)**

---

## Phase 3: Fix Public Speaking Prompts (5 scenarios)

**Muammo:** Hozirgi Public Speaking scenariolari — AI faqat tinglaydi, "Aww" deydi, "Hmm" deydi. 5 daqiqa user devorga gapirgandek bo'ladi. Bu app qiymatini yo'qqa chiqaradi.

**Yechim:** AI ni passiv tinglovchidan aktiv speech coach ga aylantirish. Har bir scenarioda AI avval tinglaydi, keyin constructive feedback va follow-up questions beradi.

**File:** `lib/features/scenarios/data/scenario_repository.dart`

### pub_1: Wedding Toast (Easy, 3 min)
- **Hozirgi:** Emily (bride's roommate) faqat "Aww" deydi
- **Yangi:** AI = wedding planner/MC who coaches before the toast, reacts during, gives quick feedback after. Interactive: "What's the main message you want to convey?" → user practices → "That opening was strong, but try to make the story about Alex more personal"

### pub_2: Acceptance Speech (Easy, 2 min → 3 min)
- **Hozirgi:** Unnamed "fellow nominee" who claps
- **Yangi:** AI = event coordinator (named Diana Wells) who briefs you before going onstage, listens, then gives feedback: "You forgot to thank the committee" / "Great emotional delivery"

### pub_3: Motivational Talk (Hard, 5 min)
- **Hozirgi:** Derek sits in audience, asks ONE question at end
- **Yangi:** AI = speaking coach (Derek) doing a practice session. Interrupts mid-speech with coaching notes: "Pause there for effect", "You lost me — can you rephrase that point?", "Great callback to your earlier story!" Active coaching, not passive listening.

### pub_4: TED-Style Talk (Hard, 5 min)
- **Hozirgi:** Dr. Lisa Huang listens silently, asks one question
- **Yangi:** AI = TED curator (Dr. Lisa Huang) in rehearsal. Stops speaker to ask: "What's your ONE big idea?", "That statistic needs a source", "Can you make that more relatable?" Provides mid-talk coaching and Q&A at end.

### pub_5: Commencement Address (Medium, 5 min)
- **Hozirgi:** Unnamed "graduating senior" who zones out
- **Yangi:** AI = university dean (Dr. Margaret Chen) in rehearsal meeting. Reviews speech structure, asks "What's your call to action for the graduates?", coaches on pacing and tone.

**Files changed: 1 | Lines changed: ~80 (5 systemPrompt rewrites)**

---

## Phase 4: Fix Prompt Bugs & Weak Characters (4 scenarios)

**File:** `lib/features/scenarios/data/scenario_repository.dart`

### 4a. Placeholder bugs
| ID | Bug | Fix |
|----|-----|-----|
| `conv_4` | Close says `[partner's name]` — AI can't resolve | Replace with concrete name "Alex" |
| `date_4` | Open says `[speaker]` — AI doesn't know user name | Replace with "Hey! You must be the friend Sarah told me about!" |
| `soc_1` | Open says `[host name]` — unresolved placeholder | Replace with concrete name "Mike" |

### 4b. Unnamed characters
| ID | Bug | Fix |
|----|-----|-----|
| `pres_4` | "a team member" — no name | Give name: "You are Lisa Park, a product designer on the team" |

**Files changed: 1 | Lines changed: ~15**

---

## Phase 5: Add "Stay in Character" Rule to Guardrails

**Muammo:** Hozirgi guardrails da "ssenariydan chiqib ketmaslik" qoidasi yo'q. Agar user boshqa mavzuga o'tsa, AI ham o'tib ketishi mumkin.

**File:** `lib/features/conversation/data/gemini_live_service.dart`

`_guardrails` ga qo'shish:
```
- Stay in character and on-topic for the entire conversation. If the user tries to change the subject or go off-script, gently steer back: "That's interesting, but let's get back to [topic]."
- Do not break character under any circumstances, even if the user asks you to.
```

Same rule to text chat fullInstruction.

**Files changed: 2 | Lines changed: ~8**

---

## Summary

| Phase | Nima | Files | Priority |
|-------|------|-------|----------|
| 1 | English-only enforcement | 3 files | CRITICAL |
| 2 | Fix short durations (6 scenarios) | 1 file | HIGH |
| 3 | Rewrite Public Speaking prompts (5 scenarios) | 1 file | HIGH |
| 4 | Fix placeholder bugs + unnamed chars (4 scenarios) | 1 file | MEDIUM |
| 5 | Stay-in-character guardrail | 2 files | HIGH |

**Total: 4 unique files modified, ~120 lines changed**

No new files, no new features, no new dependencies. Faqat mavjud code ni to'g'rilash.
