import { GoogleGenerativeAI } from "@google/generative-ai";

export interface FeedbackResult {
  clarity: number;
  confidence: number;
  engagement: number;
  relevance: number;
  overallScore: number;
  summary: string;
  strengths: string[];
  improvements: string[];
  xpEarned: number;
}

export async function generateFeedback(params: {
  transcript: string;
  category: string;
  scenarioTitle: string;
  scenarioPrompt: string;
  apiKey: string;
}): Promise<FeedbackResult> {
  const { transcript, category, scenarioTitle, scenarioPrompt, apiKey } =
    params;

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

  const categoryRubrics: Record<string, string> = {
    Interviews:
      "Scoring weights: Relevance 30%, Confidence 30%, Clarity 25%, Engagement 15%. " +
      "Relevance: Did they answer the question asked? Were examples specific and structured (STAR method)? " +
      "Confidence: Did they project authority without arrogance? Minimal hedging and filler words? " +
      "Clarity: Were answers concise and well-organized? Easy to follow? " +
      "Engagement: Did they build rapport with the interviewer? Ask good questions back?",
    Presentations:
      "Scoring weights: Clarity 30%, Confidence 25%, Engagement 25%, Relevance 20%. " +
      "Clarity: Was the structure clear (intro, body, conclusion)? Were key points easy to identify? " +
      "Confidence: Did they project executive presence? Strong vocal delivery? " +
      "Engagement: Did they hold attention? Use stories or data effectively? " +
      "Relevance: Did the content match the presentation context?",
    "Public Speaking":
      "Scoring weights: Engagement 30%, Confidence 25%, Clarity 25%, Relevance 20%. " +
      "Engagement: Did the audience stay hooked? Were there emotional peaks? " +
      "Confidence: Was delivery commanding? Good use of pauses and emphasis? " +
      "Clarity: Was the message clear and memorable? Well-structured narrative? " +
      "Relevance: Did the speech match the occasion and audience?",
    Conversations:
      "Scoring weights: Engagement 30%, Clarity 25%, Confidence 25%, Relevance 20%. " +
      "Engagement: Did they keep the conversation flowing? Ask good follow-ups? " +
      "Clarity: Were they easy to understand? Did they express thoughts coherently? " +
      "Confidence: Were they comfortable and natural? Not overly nervous? " +
      "Relevance: Did they stay on topic and respond appropriately?",
    Debates:
      "Scoring weights: Relevance 35%, Clarity 25%, Confidence 25%, Engagement 15%. " +
      "Relevance: Did arguments directly address the topic? Were rebuttals on point? " +
      "Clarity: Were arguments logically structured and easy to follow? " +
      "Confidence: Did they stand firm under pressure? Project conviction? " +
      "Engagement: Did they acknowledge opposing points? Maintain respectful dialogue?",
    Storytelling:
      "Scoring weights: Engagement 35%, Clarity 25%, Confidence 20%, Relevance 20%. " +
      "Engagement: Was the story captivating? Did it have emotional hooks? " +
      "Clarity: Was the narrative arc clear (setup, tension, resolution)? " +
      "Confidence: Was delivery natural and expressive? " +
      "Relevance: Did the story match the prompt and convey a clear message?",
    "Phone Anxiety":
      "Scoring weights: Confidence 35%, Clarity 30%, Relevance 25%, Engagement 10%. " +
      "Confidence: Did they sound calm and composed? Minimal hesitation? " +
      "Clarity: Were requests/information stated clearly? Easy to understand? " +
      "Relevance: Did they accomplish the phone call objective? " +
      "Engagement: Were they polite and appropriately conversational?",
    "Dating & Social":
      "Scoring weights: Engagement 35%, Confidence 30%, Relevance 20%, Clarity 15%. " +
      "Engagement: Was there genuine chemistry and curiosity? Good questions asked? " +
      "Confidence: Were they comfortable, natural, not overly eager or aloof? " +
      "Relevance: Did they respond appropriately to social cues? " +
      "Clarity: Were they articulate and easy to talk to?",
    "Conflict & Boundaries":
      "Scoring weights: Confidence 30%, Relevance 30%, Clarity 25%, Engagement 15%. " +
      "Confidence: Did they stay assertive without being aggressive? Hold firm? " +
      "Relevance: Did they address the actual issue directly? Stay on point? " +
      "Clarity: Was their message unambiguous? Were expectations clearly stated? " +
      "Engagement: Did they listen to the other side and show empathy?",
    "Social Situations":
      "Scoring weights: Engagement 35%, Confidence 25%, Clarity 25%, Relevance 15%. " +
      "Engagement: Did they keep the social interaction flowing? Show genuine interest? " +
      "Confidence: Were they approachable and comfortable? Natural body language? " +
      "Clarity: Did they express themselves clearly and concisely? " +
      "Relevance: Did they read social cues and respond appropriately?",
  };

  const rubric = categoryRubrics[category] || categoryRubrics["Conversations"];

  const prompt = `You are an expert speaking coach analyzing a practice conversation.

Category: ${category}
Scenario: ${scenarioTitle}
Context: ${scenarioPrompt}

${rubric}

Here is the full transcript of the conversation:
---
${transcript}
---

Analyze the speaker's performance and return ONLY a valid JSON object (no markdown, no code fences) with these fields:
{
  "clarity": <0-100 score>,
  "confidence": <0-100 score>,
  "engagement": <0-100 score>,
  "relevance": <0-100 score>,
  "overallScore": <0-100 weighted composite based on the category weights above>,
  "summary": "2-3 sentence summary of their performance",
  "strengths": ["strength1", "strength2", "strength3"],
  "improvements": ["specific improvement tip 1", "specific improvement tip 2", "specific improvement tip 3"]
}

IMPORTANT: All scores (clarity, confidence, engagement, relevance) must be on a 0-100 scale, NOT 1-10.
Be encouraging but honest. Provide specific, actionable feedback.`;

  const result = await model.generateContent(prompt);
  const text = result.response.text();

  if (!text) {
    throw new Error("Empty response from Gemini");
  }

  return parseFeedbackResponse(text);
}

function parseFeedbackResponse(text: string): FeedbackResult {
  let cleaned = text.trim();

  // Remove code fences if present
  if (cleaned.startsWith("```")) {
    cleaned = cleaned.substring(cleaned.indexOf("\n") + 1);
    if (cleaned.endsWith("```")) {
      cleaned = cleaned.substring(0, cleaned.lastIndexOf("```"));
    }
  }
  cleaned = cleaned.trim();

  const json = JSON.parse(cleaned);

  // Migration guard: if AI returned 1-10 scale, multiply to 0-100
  const normalize = (val: number, fallback: number): number => {
    const n = Number(val) || fallback;
    return n <= 10 ? n * 10 : n;
  };

  const clarity = normalize(json.clarity, 50);
  const confidence = normalize(json.confidence, 50);
  const engagement = normalize(json.engagement, 50);
  const relevance = normalize(json.relevance, 50);
  const overallScore = normalize(json.overallScore, 50);

  return {
    clarity,
    confidence,
    engagement,
    relevance,
    overallScore,
    summary: String(json.summary || ""),
    strengths: Array.isArray(json.strengths)
      ? json.strengths.map(String)
      : ["Keep practicing!"],
    improvements: Array.isArray(json.improvements)
      ? json.improvements.map(String)
      : ["Try another session for better analysis"],
    xpEarned: 50 + overallScore * 2,
  };
}
