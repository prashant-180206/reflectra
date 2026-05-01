import 'package:isar_plus/isar_plus.dart';
import 'package:reflectra/core/database/database.dart';
import 'package:reflectra/core/database/models/persona.dart';

class PersonaDb {
  static Isar get _isar => Database.isar;

  static Future<void> savePersona(Persona persona) async {
    return _isar.write((isar) {
      persona.id = 0;
      isar.personas.put(persona);
    });
  }
  
  static Future<Persona?> getPersona() async {
    return _isar.personas.get(0);
  }

  static Future<bool> deletePersona() async {
    return await _isar.write((isar) {
      return _isar.personas.delete(0);
    });
  }
}
