import 'package:mindlog/core/database/crud/persona_db.dart';
import 'package:mindlog/core/singleton.dart';
import 'package:mindlog/features/profile/utils/persona_maker.dart';

Future<int> savePersonaEntry(String personaJson) async {
  try {
    final persona = PersonaMapper.fromAiJson(personaJson);
    await PersonaDb.savePersona(persona);
    return persona.id;
  } catch (e) {
    logger.e('Error saving persona entry: $e');
    throw Exception('Failed to save persona entry');
  }
}