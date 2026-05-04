import 'dart:convert';

import 'package:reflectra/core/database/models/persona.dart';

class PersonaMapper {
  static Persona fromAiJson(String rawJson) {
    final Map<String, dynamic> jsonMap = jsonDecode(rawJson);

    return Persona(
      id: 0,

      identity: Identity(
        preferredName: _str(jsonMap, ['identity', 'preferred_name']),
        ageRange: _str(jsonMap, ['identity', 'age_range']),
        occupationOrField: _str(jsonMap, ['identity', 'occupation_or_field']),
        region: _str(jsonMap, ['identity', 'region']),
      ),

      personality: Personality(
        traits: _list(jsonMap, ['personality', 'traits']),
        thinkingStyle: _str(jsonMap, ['personality', 'thinking_style']),
        energyPattern: _str(jsonMap, ['personality', 'energy_pattern']),
        stressTriggers: _list(jsonMap, ['personality', 'stress_triggers']),
        motivationStyle: _str(jsonMap, ['personality', 'motivation_style']),
      ),

      interests: Interests(
        hobbies: _list(jsonMap, ['interests', 'hobbies']),
        mediaPreferences: MediaPreferences(
          anime: _list(jsonMap, ['interests', 'media_preferences', 'anime']),
          books: _list(jsonMap, ['interests', 'media_preferences', 'books']),
          music: _list(jsonMap, ['interests', 'media_preferences', 'music']),
          games: _list(jsonMap, ['interests', 'media_preferences', 'games']),
          other: _list(jsonMap, ['interests', 'media_preferences', 'other']),
        ),
        favoriteTopics: _list(jsonMap, ['interests', 'favorite_topics']),
      ),

      communicationPreferences: CommunicationPreferences(
        tone: _str(jsonMap, ['communication_preferences', 'tone']),
        directness: _str(jsonMap, ['communication_preferences', 'directness']),
        humorStyle: _str(jsonMap, ['communication_preferences', 'humor_style']),
        emojiPreference: _str(jsonMap, [
          'communication_preferences',
          'emoji_preference',
        ]),
        responseLengthPreference: _str(jsonMap, [
          'communication_preferences',
          'response_length_preference',
        ]),
      ),

      goals: Goals(
        shortTerm: _list(jsonMap, ['goals', 'short_term']),
        longTerm: _list(jsonMap, ['goals', 'long_term']),
        skillsBuilding: _list(jsonMap, ['goals', 'skills_building']),
        habitsWorkingOn: _list(jsonMap, ['goals', 'habits_working_on']),
      ),

      emotionalProfile: EmotionalProfile(
        stressResponse: _str(jsonMap, ['emotional_profile', 'stress_response']),
        whatDrainsThem: _list(jsonMap, [
          'emotional_profile',
          'what_drains_them',
        ]),
        whatEnergizesThem: _list(jsonMap, [
          'emotional_profile',
          'what_energizes_them',
        ]),
        preferredSupportStyle: _str(jsonMap, [
          'emotional_profile',
          'preferred_support_style',
        ]),
      ),

      additionalContext: _str(jsonMap, ['additional_context']),
    );
  }

  static Persona mergePersona(Persona? oldP, Persona newP) {
    if (oldP == null) return newP;

    return Persona(
      id: oldP.id, // preserve ID

      identity: Identity(
        preferredName: _pick(
          newP.identity?.preferredName,
          oldP.identity?.preferredName,
        ),
        ageRange: _pick(newP.identity?.ageRange, oldP.identity?.ageRange),
        occupationOrField: _pick(
          newP.identity?.occupationOrField,
          oldP.identity?.occupationOrField,
        ),
        region: _pick(newP.identity?.region, oldP.identity?.region),
      ),

      personality: Personality(
        traits: _mergeList(newP.personality?.traits, oldP.personality?.traits),
        thinkingStyle: _pick(
          newP.personality?.thinkingStyle,
          oldP.personality?.thinkingStyle,
        ),
        energyPattern: _pick(
          newP.personality?.energyPattern,
          oldP.personality?.energyPattern,
        ),
        stressTriggers: _mergeList(
          newP.personality?.stressTriggers,
          oldP.personality?.stressTriggers,
        ),
        motivationStyle: _pick(
          newP.personality?.motivationStyle,
          oldP.personality?.motivationStyle,
        ),
      ),

      interests: Interests(
        hobbies: _mergeList(newP.interests?.hobbies, oldP.interests?.hobbies),
        favoriteTopics: _mergeList(
          newP.interests?.favoriteTopics,
          oldP.interests?.favoriteTopics,
        ),

        mediaPreferences: MediaPreferences(
          anime: _mergeList(
            newP.interests?.mediaPreferences?.anime,
            oldP.interests?.mediaPreferences?.anime,
          ),
          books: _mergeList(
            newP.interests?.mediaPreferences?.books,
            oldP.interests?.mediaPreferences?.books,
          ),
          music: _mergeList(
            newP.interests?.mediaPreferences?.music,
            oldP.interests?.mediaPreferences?.music,
          ),
          games: _mergeList(
            newP.interests?.mediaPreferences?.games,
            oldP.interests?.mediaPreferences?.games,
          ),
          other: _mergeList(
            newP.interests?.mediaPreferences?.other,
            oldP.interests?.mediaPreferences?.other,
          ),
        ),
      ),

      communicationPreferences: CommunicationPreferences(
        tone: _pick(
          newP.communicationPreferences?.tone,
          oldP.communicationPreferences?.tone,
        ),
        directness: _pick(
          newP.communicationPreferences?.directness,
          oldP.communicationPreferences?.directness,
        ),
        humorStyle: _pick(
          newP.communicationPreferences?.humorStyle,
          oldP.communicationPreferences?.humorStyle,
        ),
        emojiPreference: _pick(
          newP.communicationPreferences?.emojiPreference,
          oldP.communicationPreferences?.emojiPreference,
        ),
        responseLengthPreference: _pick(
          newP.communicationPreferences?.responseLengthPreference,
          oldP.communicationPreferences?.responseLengthPreference,
        ),
      ),

      goals: Goals(
        shortTerm: _mergeList(newP.goals?.shortTerm, oldP.goals?.shortTerm),
        longTerm: _mergeList(newP.goals?.longTerm, oldP.goals?.longTerm),
        skillsBuilding: _mergeList(
          newP.goals?.skillsBuilding,
          oldP.goals?.skillsBuilding,
        ),
        habitsWorkingOn: _mergeList(
          newP.goals?.habitsWorkingOn,
          oldP.goals?.habitsWorkingOn,
        ),
      ),

      emotionalProfile: EmotionalProfile(
        stressResponse: _pick(
          newP.emotionalProfile?.stressResponse,
          oldP.emotionalProfile?.stressResponse,
        ),
        whatDrainsThem: _mergeList(
          newP.emotionalProfile?.whatDrainsThem,
          oldP.emotionalProfile?.whatDrainsThem,
        ),
        whatEnergizesThem: _mergeList(
          newP.emotionalProfile?.whatEnergizesThem,
          oldP.emotionalProfile?.whatEnergizesThem,
        ),
        preferredSupportStyle: _pick(
          newP.emotionalProfile?.preferredSupportStyle,
          oldP.emotionalProfile?.preferredSupportStyle,
        ),
      ),

      additionalContext:
          _pick(newP.additionalContext, oldP.additionalContext) ?? '',
    );
  }

  // ---------- Safe Helpers ----------

  static String? _pick(String? newVal, String? oldVal) {
    if (newVal == null || newVal.trim().isEmpty) return oldVal;
    return newVal.trim();
  }

  static List<String>? _mergeList(List<String>? newVal, List<String>? oldVal) {
    final newList = (newVal ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    final oldList = (oldVal ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);

    final combined = {...oldList, ...newList}.toList();

    return combined.isEmpty ? null : combined;
  }

  static String _str(Map<String, dynamic> map, List<String> path) {
    dynamic current = map;
    for (final key in path) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return '';
      }
    }
    return current?.toString() ?? '';
  }

  static List<String> _list(Map<String, dynamic> map, List<String> path) {
    dynamic current = map;
    for (final key in path) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return [];
      }
    }

    if (current is List) {
      return current.map((e) => e.toString()).toList();
    }

    return [];
  }
}
