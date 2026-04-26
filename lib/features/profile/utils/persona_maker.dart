import 'dart:convert';

import 'package:mindlog/core/database/models/persona.dart';

class PersonaMapper {
  static Persona fromAiJson(String rawJson) {
    final Map<String, dynamic> jsonMap = jsonDecode(rawJson);

    return Persona(
      id: 0,

      identity: Identity(
        preferredName: _str(jsonMap, ['identity', 'preferred_name']),
        ageRange: _str(jsonMap, ['identity', 'age_range']),
        occupationOrField:
            _str(jsonMap, ['identity', 'occupation_or_field']),
        region: _str(jsonMap, ['identity', 'region']),
      ),

      personality: Personality(
        traits: _list(jsonMap, ['personality', 'traits']),
        thinkingStyle:
            _str(jsonMap, ['personality', 'thinking_style']),
        energyPattern:
            _str(jsonMap, ['personality', 'energy_pattern']),
        stressTriggers:
            _list(jsonMap, ['personality', 'stress_triggers']),
        motivationStyle:
            _str(jsonMap, ['personality', 'motivation_style']),
      ),

      interests: Interests(
        hobbies: _list(jsonMap, ['interests', 'hobbies']),
        mediaPreferences: MediaPreferences(
          anime: _list(jsonMap,
              ['interests', 'media_preferences', 'anime']),
          books: _list(jsonMap,
              ['interests', 'media_preferences', 'books']),
          music: _list(jsonMap,
              ['interests', 'media_preferences', 'music']),
          games: _list(jsonMap,
              ['interests', 'media_preferences', 'games']),
          other: _list(jsonMap,
              ['interests', 'media_preferences', 'other']),
        ),
        favoriteTopics:
            _list(jsonMap, ['interests', 'favorite_topics']),
      ),

      communicationPreferences: CommunicationPreferences(
        tone: _str(jsonMap,
            ['communication_preferences', 'tone']),
        directness: _str(jsonMap,
            ['communication_preferences', 'directness']),
        humorStyle: _str(jsonMap,
            ['communication_preferences', 'humor_style']),
        emojiPreference: _str(jsonMap,
            ['communication_preferences', 'emoji_preference']),
        responseLengthPreference: _str(jsonMap,
            ['communication_preferences',
             'response_length_preference']),
      ),

      goals: Goals(
        shortTerm: _list(jsonMap, ['goals', 'short_term']),
        longTerm: _list(jsonMap, ['goals', 'long_term']),
        skillsBuilding:
            _list(jsonMap, ['goals', 'skills_building']),
        habitsWorkingOn:
            _list(jsonMap, ['goals', 'habits_working_on']),
      ),

      emotionalProfile: EmotionalProfile(
        stressResponse:
            _str(jsonMap, ['emotional_profile', 'stress_response']),
        whatDrainsThem:
            _list(jsonMap, ['emotional_profile', 'what_drains_them']),
        whatEnergizesThem:
            _list(jsonMap, ['emotional_profile', 'what_energizes_them']),
        preferredSupportStyle:
            _str(jsonMap,
                ['emotional_profile', 'preferred_support_style']),
      ),

      additionalContext: _str(jsonMap, ['additional_context']),
    );
  }

  // ---------- Safe Helpers ----------

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