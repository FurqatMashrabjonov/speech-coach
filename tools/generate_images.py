#!/usr/bin/env python3
"""Generate all app images using Gemini API and compress for mobile.

Usage:
  python tools/generate_images.py --api-key <GEMINI_KEY>
  python tools/generate_images.py --api-key <KEY> --only categories
  python tools/generate_images.py --api-key <KEY> --only characters
  python tools/generate_images.py --api-key <KEY> --only mascots
  python tools/generate_images.py --compress-only
"""

import argparse
import io
import os
import sys
import time
from pathlib import Path

# ---------------------------------------------------------------------------
# Style prefix shared by every prompt
# ---------------------------------------------------------------------------
STYLE_PREFIX = (
    "Flat vector illustration, minimal clean design, soft rounded shapes, "
    "Duolingo-style cartoon aesthetic, vibrant but not oversaturated colors, "
    "clean white background, centered composition, no text, no borders, "
    "suitable as a mobile app icon at small sizes. "
)

# ---------------------------------------------------------------------------
# Image definitions — file paths match AppImages constants exactly
# ---------------------------------------------------------------------------
CATEGORIES = [
    (
        "assets/images/categories/category_interviews.png",
        "A person in a suit sitting across a desk from an interviewer in a bright office, professional job interview scene",
    ),
    (
        "assets/images/categories/category_presentations.png",
        "A confident person standing at a podium with presentation slides behind them, giving a talk",
    ),
    (
        "assets/images/categories/category_public_speaking.png",
        "A person speaking into a microphone on a stage with spotlight, audience silhouettes",
    ),
    (
        "assets/images/categories/category_conversations.png",
        "Two people having a friendly casual conversation at a coffee shop, relaxed vibe",
    ),
    (
        "assets/images/categories/category_debates.png",
        "Two people at podiums facing each other in a debate, speech bubbles in air",
    ),
    (
        "assets/images/categories/category_storytelling.png",
        "A person sitting in an armchair telling a story with magical swirls and book pages floating",
    ),
    (
        "assets/images/categories/category_phone_anxiety.png",
        "A person nervously holding a phone to their ear, small sweat drops, gentle encouragement vibe",
    ),
    (
        "assets/images/categories/category_dating.png",
        "Two people at a small cafe table, first date vibe, warm hearts floating subtly",
    ),
    (
        "assets/images/categories/category_conflict.png",
        "A person standing firm with a confident stance, setting boundaries, shield icon nearby",
    ),
    (
        "assets/images/categories/category_social.png",
        "A group of people at a social gathering mingling, warm party lights, friendly vibe",
    ),
]

CHARACTERS = [
    # --- Original 8 ---
    (
        "assets/images/characters/character_alex.png",
        "Head-and-shoulders portrait of a sharp professional male coach in his 30s, direct confident expression, wearing a blazer, blue accent colors",
    ),
    (
        "assets/images/characters/character_sam.png",
        "Head-and-shoulders portrait of a friendly upbeat person with a big warm smile, casual outfit, green accent colors",
    ),
    (
        "assets/images/characters/character_morgan.png",
        "Head-and-shoulders portrait of a wise experienced mentor in their 50s, thoughtful gentle expression, warm orange accent",
    ),
    (
        "assets/images/characters/character_jordan.png",
        "Head-and-shoulders portrait of an energetic sharp debater in their 20s, excited clever expression, red accent colors",
    ),
    (
        "assets/images/characters/character_riley.png",
        "Head-and-shoulders portrait of a friendly professional interviewer, warm approachable smile, sky blue accent",
    ),
    (
        "assets/images/characters/character_kai.png",
        "Head-and-shoulders portrait of a creative expressive storyteller, whimsical artistic vibe, golden yellow accent",
    ),
    (
        "assets/images/characters/character_taylor.png",
        "Head-and-shoulders portrait of a firm authoritative executive, polished powerful look, gold accent",
    ),
    (
        "assets/images/characters/character_avery.png",
        "Head-and-shoulders portrait of a warm supportive guide, gentle encouraging smile, soft orange accent",
    ),
    # --- 22 New Characters ---
    (
        "assets/images/characters/character_luna.png",
        "Head-and-shoulders portrait of an energetic young female life coach with bright eyes and radiant smile, sporty outfit, bright blue accent colors",
    ),
    (
        "assets/images/characters/character_viktor.png",
        "Head-and-shoulders portrait of a stern disciplined male military trainer in his 40s, buzz cut, serious focused expression, dark grey and navy accent",
    ),
    (
        "assets/images/characters/character_priya.png",
        "Head-and-shoulders portrait of a cheerful Indian female podcast host in her 20s, headphones around neck, curious bright expression, warm orange accent",
    ),
    (
        "assets/images/characters/character_sage.png",
        "Head-and-shoulders portrait of a calm relaxed therapist with gentle knowing smile, casual earth-tone outfit, green accent colors",
    ),
    (
        "assets/images/characters/character_nadia.png",
        "Head-and-shoulders portrait of an articulate female science teacher with glasses, precise confident expression, purple accent colors",
    ),
    (
        "assets/images/characters/character_sunny.png",
        "Head-and-shoulders portrait of a bubbly energetic morning show host with big bright smile, colorful outfit, yellow and orange accent",
    ),
    (
        "assets/images/characters/character_dev.png",
        "Head-and-shoulders portrait of a measured analytical male tech lead in his 30s, neat appearance, calm collected look, blue accent colors",
    ),
    (
        "assets/images/characters/character_rio.png",
        "Head-and-shoulders portrait of an animated quick-witted comedian with a playful mischievous grin, expressive eyes, red and pink accent",
    ),
    (
        "assets/images/characters/character_ethan.png",
        "Head-and-shoulders portrait of a calm serene male meditation guide with peaceful closed-eye smile, minimal zen outfit, teal and mint accent",
    ),
    (
        "assets/images/characters/character_omar.png",
        "Head-and-shoulders portrait of a smooth charming male radio DJ in his 30s with a suave confident smile, headphones, warm orange accent",
    ),
    (
        "assets/images/characters/character_rex.png",
        "Head-and-shoulders portrait of a tough bold male personal trainer with strong jawline and intense motivating expression, athletic wear, red accent",
    ),
    (
        "assets/images/characters/character_iris.png",
        "Head-and-shoulders portrait of a gentle soothing female counselor with soft compassionate expression, kind eyes, lavender and light purple accent",
    ),
    (
        "assets/images/characters/character_jake.png",
        "Head-and-shoulders portrait of a laid-back surfer dude with messy hair and relaxed easygoing grin, tank top, teal and aqua accent",
    ),
    (
        "assets/images/characters/character_dr_nash.png",
        "Head-and-shoulders portrait of a wise male researcher in his 50s with reading glasses and deep thoughtful expression, tweed jacket, dark blue accent",
    ),
    (
        "assets/images/characters/character_marcus.png",
        "Head-and-shoulders portrait of a scholarly patient male professor with warm welcoming expression, bow tie, indigo and blue accent",
    ),
    (
        "assets/images/characters/character_zoe.png",
        "Head-and-shoulders portrait of a young enthusiastic female intern in her early 20s with eager excited expression, bright casual outfit, pink accent",
    ),
    (
        "assets/images/characters/character_maya.png",
        "Head-and-shoulders portrait of a relaxed friendly female bartender with great-listener expression, casual apron, green and mint accent",
    ),
    (
        "assets/images/characters/character_leo.png",
        "Head-and-shoulders portrait of a composed direct male news anchor with polished professional look, suit and tie, sky blue accent",
    ),
    (
        "assets/images/characters/character_elena.png",
        "Head-and-shoulders portrait of a sophisticated tactful female diplomat with elegant confident expression, formal attire, light purple accent",
    ),
    (
        "assets/images/characters/character_prof_chen.png",
        "Head-and-shoulders portrait of a patient informative male university professor in his 60s with kind wise expression, glasses, grey and blue accent",
    ),
    (
        "assets/images/characters/character_aria.png",
        "Head-and-shoulders portrait of a bold driven female startup founder in her 30s with fierce determined expression, modern blazer, red accent",
    ),
    (
        "assets/images/characters/character_grace.png",
        "Head-and-shoulders portrait of a kind nurturing grandmother figure in her 60s with warm loving smile, cozy sweater, soft pink accent",
    ),
]

# Mascots are ordered so that mascot_welcome is generated first (used as
# reference for the rest to keep the character design consistent).
MASCOT_BASE_DESC = "A cute round speech bubble mascot character with small arms and legs"

MASCOTS = [
    (
        "assets/images/mascot/mascot_welcome.png",
        f"{MASCOT_BASE_DESC}, waving hello, cheerful big eyes, friendly smile",
    ),
    (
        "assets/images/mascot/mascot_analyze.png",
        f"Same cute speech bubble mascot holding a magnifying glass, curious thinking expression",
    ),
    (
        "assets/images/mascot/mascot_celebrate.png",
        f"Same cute speech bubble mascot jumping with confetti around it, excited celebration pose",
    ),
    (
        "assets/images/mascot/mascot_speak.png",
        f"Same cute speech bubble mascot with sound waves coming from mouth, speaking pose",
    ),
    (
        "assets/images/mascot/mascot_premium.png",
        f"Same cute speech bubble mascot wearing a small golden crown, premium sparkles",
    ),
    (
        "assets/images/mascot/mascot_empty.png",
        f"Same cute speech bubble mascot looking around with empty hands, slightly confused",
    ),
    (
        "assets/images/mascot/mascot_error.png",
        f"Same cute speech bubble mascot with a small bandage, apologetic sad expression",
    ),
    (
        "assets/images/mascot/mascot_happy.png",
        f"Same cute speech bubble mascot with huge smile and sparkle eyes, radiating joy",
    ),
    (
        "assets/images/mascot/mascot_impressed.png",
        f"Same cute speech bubble mascot with wide surprised eyes, clapping hands, wow expression",
    ),
    (
        "assets/images/mascot/mascot_encouraging.png",
        f"Same cute speech bubble mascot giving thumbs up, supportive warm expression",
    ),
    (
        "assets/images/mascot/mascot_coaching.png",
        f"Same cute speech bubble mascot wearing tiny glasses, pointing at a small board, teacher pose",
    ),
    (
        "assets/images/mascot/mascot_thinking.png",
        f"Same cute speech bubble mascot with hand on chin, thought bubble above head",
    ),
]

SCENARIOS = [
    # --- Interviews ---
    ("assets/images/scenarios/scenario_int_1.png", "A person confidently introducing themselves at a desk across from an interviewer, professional office, name tag visible"),
    ("assets/images/scenarios/scenario_int_2.png", "Two coworkers having a tense conversation at work, one calmly explaining with hand gestures, conflict resolution"),
    ("assets/images/scenarios/scenario_int_3.png", "A person at a whiteboard drawing system architecture diagrams, technical interview setting"),
    ("assets/images/scenarios/scenario_int_4.png", "A person at a desk confidently discussing numbers with their boss, dollar signs and chart, salary negotiation"),
    ("assets/images/scenarios/scenario_int_5.png", "A person standing tall with a spotlight on them, star and sparkles, confident hiring pitch moment"),
    # --- Presentations ---
    ("assets/images/scenarios/scenario_pres_1.png", "A person in an elevator giving a quick pitch to a business person, clock showing 30 seconds, elevator pitch"),
    ("assets/images/scenarios/scenario_pres_2.png", "A person presenting bar charts and pie charts on a screen to a boardroom, quarterly business review"),
    ("assets/images/scenarios/scenario_pres_3.png", "A person demonstrating a product on a laptop to an excited audience, product demo"),
    ("assets/images/scenarios/scenario_pres_4.png", "A person speaking at the front of a team meeting room, colleagues sitting around, all-hands update"),
    ("assets/images/scenarios/scenario_pres_5.png", "A person presenting to investors with a pitch deck slide showing a growth arrow, investor meeting"),
    # --- Public Speaking ---
    ("assets/images/scenarios/scenario_pub_1.png", "A person raising a glass giving a wedding toast, champagne glasses, flowers, celebration"),
    ("assets/images/scenarios/scenario_pub_2.png", "A person at a podium holding a trophy, giving an acceptance speech, spotlight"),
    ("assets/images/scenarios/scenario_pub_3.png", "A person on stage giving a motivational talk, fire emoji vibe, inspired audience"),
    ("assets/images/scenarios/scenario_pub_4.png", "A person on a round red stage like TED, giving a passionate talk with hand gestures"),
    ("assets/images/scenarios/scenario_pub_5.png", "A person in academic gown at a podium, graduation caps in air, commencement speech"),
    # --- Debates ---
    ("assets/images/scenarios/scenario_deb_1.png", "A robot and a teacher at debate podiums facing each other, AI vs education theme"),
    ("assets/images/scenarios/scenario_deb_2.png", "Split scene: one person at home office, another in a corporate office, versus sign between"),
    ("assets/images/scenarios/scenario_deb_3.png", "A large phone screen with social media icons, thumbs up and thumbs down, debate about harm"),
    ("assets/images/scenarios/scenario_deb_4.png", "Money bills raining down on diverse people, scales of justice, universal basic income concept"),
    ("assets/images/scenarios/scenario_deb_5.png", "A rocket launching into space with dollar bills, space exploration versus budget debate"),
    # --- Conversations ---
    ("assets/images/scenarios/scenario_conv_1.png", "Two people at a networking event with name badges, shaking hands, drinks in hand"),
    ("assets/images/scenarios/scenario_conv_2.png", "A nervous person approaching someone at a park bench, heart floating, asking someone out"),
    ("assets/images/scenarios/scenario_conv_3.png", "A person with a sorry expression offering flowers to a friend, apologizing scene"),
    ("assets/images/scenarios/scenario_conv_4.png", "A couple sitting on a couch with older parents, family meeting, warm living room"),
    ("assets/images/scenarios/scenario_conv_5.png", "A person at a desk giving feedback to a colleague, speech bubble with constructive icons"),
    # --- Storytelling ---
    ("assets/images/scenarios/scenario_story_1.png", "A person reminiscing with a thought bubble showing childhood playground, nostalgic warm vibe"),
    ("assets/images/scenarios/scenario_story_2.png", "A person on a mountain peak with arms raised, trophy glow, proudest achievement moment"),
    ("assets/images/scenarios/scenario_story_3.png", "A person laughing telling a story to friends around a campfire, comedy vibe, laugh emojis"),
    ("assets/images/scenarios/scenario_story_4.png", "A person with a lightbulb above their head, broken road behind them, lesson learned the hard way"),
    ("assets/images/scenarios/scenario_story_5.png", "A person with a backpack and suitcase at an airport, travel stamps, adventure vibe"),
    # --- Phone Anxiety ---
    ("assets/images/scenarios/scenario_phone_1.png", "A person on the phone with a takeout food menu, pizza and burger icons floating, ordering food"),
    ("assets/images/scenarios/scenario_phone_2.png", "A person nervously calling on phone with a hospital cross icon, doctor appointment call"),
    ("assets/images/scenarios/scenario_phone_3.png", "A person in bed with a phone and thermometer, calling in sick, tissue box nearby"),
    ("assets/images/scenarios/scenario_phone_4.png", "A person on the phone with a restaurant table icon, making a reservation, calendar"),
    ("assets/images/scenarios/scenario_phone_5.png", "A person on the phone holding a package with return arrow, returning an item"),
    # --- Dating & Social ---
    ("assets/images/scenarios/scenario_date_1.png", "Two people at a cozy cafe on a first date, coffee cups, warm candle light, butterflies"),
    ("assets/images/scenarios/scenario_date_2.png", "A person nervously approaching someone with a rose behind their back, asking them out"),
    ("assets/images/scenarios/scenario_date_3.png", "Two people at a small table with a timer, speed dating round, quick conversation"),
    ("assets/images/scenarios/scenario_date_4.png", "A group of friends at a casual hangout, two people being introduced by a mutual friend"),
    ("assets/images/scenarios/scenario_date_5.png", "Two old friends meeting and hugging warmly, nostalgia bubbles, reconnecting"),
    # --- Conflict & Boundaries ---
    ("assets/images/scenarios/scenario_conf_1.png", "A person at a boss's desk pointing at a salary chart going up, confident ask for raise"),
    ("assets/images/scenarios/scenario_conf_2.png", "A person holding up a gentle stop hand to a friend, boundary line drawn, kind but firm"),
    ("assets/images/scenarios/scenario_conf_3.png", "Two roommates in a living room, one calmly pointing at a messy area, confrontation"),
    ("assets/images/scenarios/scenario_conf_4.png", "A person at a desk with stacked papers, holding up a hand saying no, work-life balance"),
    ("assets/images/scenarios/scenario_conf_5.png", "A person listening calmly to feedback with a shield of confidence, handling criticism"),
    # --- Social Situations ---
    ("assets/images/scenarios/scenario_soc_1.png", "People at a house party chatting in small groups, balloons, casual fun vibe, small talk"),
    ("assets/images/scenarios/scenario_soc_2.png", "A person at a professional event extending a handshake with a confident smile, networking"),
    ("assets/images/scenarios/scenario_soc_3.png", "A person at a dinner table passing food and chatting with other guests, dinner party"),
    ("assets/images/scenarios/scenario_soc_4.png", "Two neighbors chatting over a fence in a friendly neighborhood, waving, casual"),
    ("assets/images/scenarios/scenario_soc_5.png", "Two strangers sitting in a waiting room, one starting a friendly conversation, magazines"),
]

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
MAX_SIZE = 512  # px — longest side after resize
TARGET_QUALITY = 6  # PNG compress_level (0-9, higher = smaller)
MAX_RETRIES = 3
RETRY_DELAY = 5  # seconds


# ---------------------------------------------------------------------------
# Compression
# ---------------------------------------------------------------------------
def compress_image(path: Path) -> None:
    """Resize to 512x512 max, RGBA, optimized PNG."""
    from PIL import Image

    img = Image.open(path)
    img = img.convert("RGBA")

    # Resize preserving aspect ratio
    if img.width > MAX_SIZE or img.height > MAX_SIZE:
        img.thumbnail((MAX_SIZE, MAX_SIZE), Image.Resampling.LANCZOS)

    # Quantize to reduce palette (keeps transparency)
    try:
        quantized = img.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG)
        quantized = quantized.convert("RGBA")
        out = quantized
    except Exception:
        out = img

    out.save(path, "PNG", optimize=True, compress_level=TARGET_QUALITY)
    size_kb = path.stat().st_size / 1024
    print(f"  Compressed {path.name}: {size_kb:.1f} KB")


def compress_all(root: Path) -> None:
    """Compress every PNG under root."""
    pngs = sorted(root.rglob("*.png"))
    if not pngs:
        print("No PNGs found to compress.")
        return
    print(f"\nCompressing {len(pngs)} images...")
    for p in pngs:
        compress_image(p)
    total = sum(p.stat().st_size for p in pngs) / 1024
    print(f"\nTotal size: {total:.1f} KB ({len(pngs)} files)")


# ---------------------------------------------------------------------------
# Generation
# ---------------------------------------------------------------------------
def generate_image(client, prompt: str, reference_bytes=None):
    """Call Gemini to generate an image. Returns (PIL Image, raw PNG bytes).
    reference_bytes should be raw PNG bytes for style consistency."""
    from PIL import Image
    from google.genai import types

    full_prompt = STYLE_PREFIX + prompt

    contents: list = []
    if reference_bytes is not None:
        ref_part = types.Part.from_bytes(data=reference_bytes, mime_type="image/png")
        contents.append(ref_part)
        contents.append("Generate an image of the same character in a new pose. " + full_prompt)
    else:
        contents.append(full_prompt)

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = client.models.generate_content(
                model="gemini-3.1-flash-image-preview",
                contents=contents,
            )

            # Extract image from response parts
            for part in response.parts:
                if part.inline_data is not None:
                    raw = part.inline_data.data
                    return Image.open(io.BytesIO(raw)), raw

            print(f"  Warning: no image in response (attempt {attempt})")
        except Exception as e:
            print(f"  Error (attempt {attempt}/{MAX_RETRIES}): {e}")
            if attempt < MAX_RETRIES:
                time.sleep(RETRY_DELAY * attempt)

    raise RuntimeError(f"Failed to generate image after {MAX_RETRIES} attempts")


def generate_group(
    client,
    items: list[tuple[str, str]],
    root: Path,
    group_name: str,
    use_reference: bool = False,
) -> None:
    """Generate a group of images. If use_reference, the first image is used
    as a reference for subsequent ones (mascot consistency)."""
    print(f"\n{'='*60}")
    print(f"Generating {group_name} ({len(items)} images)")
    print(f"{'='*60}")

    reference_bytes = None

    for i, (rel_path, prompt) in enumerate(items):
        out_path = root / rel_path
        out_path.parent.mkdir(parents=True, exist_ok=True)

        if out_path.exists():
            print(f"\n[{i+1}/{len(items)}] SKIP (exists): {rel_path}")
            # If this is the first mascot, load its bytes as reference
            if use_reference and i == 0:
                reference_bytes = out_path.read_bytes()
            continue

        print(f"\n[{i+1}/{len(items)}] Generating: {rel_path}")
        print(f"  Prompt: {prompt[:80]}...")

        ref = reference_bytes if use_reference else None

        img, raw_bytes = generate_image(client, prompt, reference_bytes=ref)
        img.save(str(out_path))
        print(f"  Saved: {out_path} ({out_path.stat().st_size / 1024:.1f} KB)")

        # Store first mascot bytes as reference
        if use_reference and i == 0:
            reference_bytes = raw_bytes

        # Rate limit — be polite to the API
        time.sleep(2)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    parser = argparse.ArgumentParser(description="Generate app images via Gemini API")
    parser.add_argument("--api-key", help="Gemini API key (or set GEMINI_API_KEY env var)")
    parser.add_argument(
        "--only",
        choices=["categories", "characters", "mascots", "scenarios"],
        help="Generate only one group",
    )
    parser.add_argument(
        "--compress-only",
        action="store_true",
        help="Skip generation, just compress existing PNGs",
    )
    args = parser.parse_args()

    # Resolve project root (script lives in tools/)
    root = Path(__file__).resolve().parent.parent

    if args.compress_only:
        compress_all(root / "assets" / "images")
        return

    # Resolve API key
    api_key = args.api_key or os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: provide --api-key or set GEMINI_API_KEY env var")
        sys.exit(1)

    from google import genai

    client = genai.Client(api_key=api_key)

    groups = {
        "categories": (CATEGORIES, "Categories", False),
        "characters": (CHARACTERS, "Characters", False),
        "mascots": (MASCOTS, "Mascots (with reference)", True),
        "scenarios": (SCENARIOS, "Scenarios", False),
    }

    if args.only:
        items, name, use_ref = groups[args.only]
        generate_group(client, items, root, name, use_reference=use_ref)
    else:
        for key in ["categories", "characters", "mascots", "scenarios"]:
            items, name, use_ref = groups[key]
            generate_group(client, items, root, name, use_reference=use_ref)

    # Compress all generated images
    compress_all(root / "assets" / "images")

    # Summary
    pngs = list((root / "assets" / "images").rglob("*.png"))
    print(f"\n{'='*60}")
    print(f"Done! {len(pngs)} images generated.")
    total_kb = sum(p.stat().st_size for p in pngs) / 1024
    print(f"Total size: {total_kb:.1f} KB")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
