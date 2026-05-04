import 'package:reflectra/core/AI/ai.dart';
import 'package:reflectra/core/database/db_service.dart';
import 'package:reflectra/core/singleton.dart';
import 'package:reflectra/features/profile/utils/persona_maker.dart';

Future<bool> setPersonaFromEntries() async {
  final entries = await DbService.getLastEntries(limit: 6);
  final prevPersona = await DbService.getPersona();

  if (entries.isEmpty) {
    logger.w("No entries found. Skipping persona generation.");
    return false;
  }

  final service = OllamaBaseService();
  await service.init();

  final entriesText = entries
      .map((e) => "- ${e.title}: ${e.content.replaceAll('\n', ' ')}")
      .join('\n');

  final prevPersonaText = prevPersona == null ? 'None' : prevPersona.toString();

  final prompt =
      """
You are a system that updates a user's persona based on recent diary entries.

Your task is NOT to generate a new persona from scratch.

Your task is to:
1. START from the previous persona (this is the base truth)
2. Carefully UPDATE only fields where strong new evidence exists
3. RETURN the FULL updated persona (all fields filled, not partial)

---

INPUT:

Recent Entries:
$entriesText

Previous Persona (BASE STATE — MUST BE PRESERVED):
$prevPersonaText

---

CRITICAL RULES:

1. Output ONLY valid JSON
2. No explanation, no markdown, no extra text
3. NEVER remove or blank out existing data unless there is strong contradictory evidence
4. If no new information exists → KEEP previous value EXACTLY
5. Do NOT hallucinate or invent data
6. Prefer repeated patterns over single mentions
7. Ignore temporary moods unless clearly recurring

---

UPDATE LOGIC:

- Strong new evidence → update that field
- Weak or no evidence → KEEP previous value
- Contradiction across multiple entries → update carefully
- Single mention → IGNORE

---

FIELD BEHAVIOR:

Identity:
- Almost always stable → change ONLY if explicitly stated

Personality:
- Update ONLY if repeated behavioral patterns appear

Communication:
- Update ONLY if consistent tone/behavior is observed

Interests:
- Add ONLY if recurring
- Do NOT remove existing interests unless clearly outdated

Emotional Patterns:
- Update ONLY if patterns repeat across entries

Goals:
- Update if clearly stated or consistently implied

---

IMPORTANT:

- You are MODIFYING an existing persona, not recreating it
- The final output MUST be a COMPLETE persona JSON
- DO NOT leave fields empty if they already exist in previous persona
- Empty fields are allowed ONLY if both:
  (a) previous persona is empty AND
  (b) no evidence exists

---

OUTPUT SCHEMA (STRICT):

{
  "identity": {
    "preferred_name": "",
    "age_range": "",
    "occupation_or_field": "",
    "region": ""
  },
  "personality": {
    "traits": [],
    "thinking_style": "",
    "energy_pattern": "",
    "stress_triggers": [],
    "motivation_style": ""
  },
  "interests": {
    "hobbies": [],
    "media_preferences": {
      "anime": [],
      "books": [],
      "music": [],
      "games": [],
      "other": []
    },
    "favorite_topics": []
  },
  "communication_preferences": {
    "tone": "",
    "directness": "",
    "humor_style": "",
    "emoji_preference": "",
    "response_length_preference": ""
  },
  "goals": {
    "short_term": [],
    "long_term": [],
    "skills_building": [],
    "habits_working_on": []
  },
  "emotional_profile": {
    "stress_response": "",
    "what_drains_them": [],
    "what_energizes_them": [],
    "preferred_support_style": ""
  },
  "additional_context": ""
}
""";

  final response = await service.processOnePrompt(prompt);

  if (response == null || response.trim().isEmpty) {
    logger.e("No response from AI for persona generation.");
    return false;
  }

  try {
    final persona = PersonaMapper.fromAiJson(response);
    final updatedpersona = PersonaMapper.mergePersona(prevPersona, persona);
    await DbService.savePersona(updatedpersona);
    return true;
  } catch (e) {
    logger.e("Failed to parse persona JSON: $e\n$response");
    return false;
  } finally {
    service.close();
  }
}
