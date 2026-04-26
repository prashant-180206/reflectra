import 'package:isar_plus/isar_plus.dart';

part 'persona.g.dart';

@collection
class Persona {
  Persona({
    this.id = 0,
    this.identity,
    this.personality,
    this.interests,
    this.communicationPreferences,
    this.goals,
    this.emotionalProfile,
    this.additionalContext = '',
  });

  int id; // Primary Key

  Identity? identity;
  Personality? personality;
  Interests? interests;
  CommunicationPreferences? communicationPreferences;
  Goals? goals;
  EmotionalProfile? emotionalProfile;

  String additionalContext;
}

@embedded
class Identity {
  Identity({
    this.preferredName,
    this.ageRange,
    this.occupationOrField,
    this.region,
  });

  String? preferredName;
  String? ageRange;
  String? occupationOrField;
  String? region;
}

@embedded
class Personality {
  Personality({
    this.traits,
    this.thinkingStyle,
    this.energyPattern,
    this.stressTriggers,
    this.motivationStyle,
  });

  List<String>? traits;
  String? thinkingStyle;
  String? energyPattern;
  List<String>? stressTriggers;
  String? motivationStyle;
}

@embedded
class Interests {
  Interests({
    this.hobbies,
    this.mediaPreferences,
    this.favoriteTopics,
  });

  List<String>? hobbies;
  MediaPreferences? mediaPreferences;
  List<String>? favoriteTopics;
}

@embedded
class MediaPreferences {
  MediaPreferences({
    this.anime,
    this.books,
    this.music,
    this.games,
    this.other,
  });

  List<String>? anime;
  List<String>? books;
  List<String>? music;
  List<String>? games;
  List<String>? other;
}

@embedded
class CommunicationPreferences {
  CommunicationPreferences({
    this.tone,
    this.directness,
    this.humorStyle,
    this.emojiPreference,
    this.responseLengthPreference,
  });

  String? tone;
  String? directness;
  String? humorStyle;
  String? emojiPreference;
  String? responseLengthPreference;
}

@embedded
class Goals {
  Goals({
    this.shortTerm,
    this.longTerm,
    this.skillsBuilding,
    this.habitsWorkingOn,
  });

  List<String>? shortTerm;
  List<String>? longTerm;
  List<String>? skillsBuilding;
  List<String>? habitsWorkingOn;
}

@embedded
class EmotionalProfile {
  EmotionalProfile({
    this.stressResponse,
    this.whatDrainsThem,
    this.whatEnergizesThem,
    this.preferredSupportStyle,
  });

  String? stressResponse;
  List<String>? whatDrainsThem;
  List<String>? whatEnergizesThem;
  String? preferredSupportStyle;
}