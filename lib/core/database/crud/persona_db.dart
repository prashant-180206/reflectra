import 'package:reflectra/core/database/db_service.dart';
import 'package:reflectra/core/database/models/persona.dart';

/// Deprecated: Use DbService instead for new code.
/// This class maintains backwards compatibility.
class PersonaDb {
  static Future<void> savePersona(Persona persona) =>
      DbService.savePersona(persona);

  static Future<Persona?> getPersona() =>
      DbService.getPersona();

  static Future<bool> deletePersona() =>
      DbService.deletePersona();
}
