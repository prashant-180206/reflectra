import 'package:isar_plus/isar_plus.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:mindlog/core/database/models/persona.dart';
import 'package:path_provider/path_provider.dart';

class Database {
  static late Isar isar;
  static const String _dbName = 'mindlog_diary_v2';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = Isar.open(
      schemas: [DiaryEntrySchema, PersonaSchema],
      directory: dir.path,
      name: _dbName,
    );
  }

  // Dev helper to clear local diary data for this schema version.
  static Future<void> resetCurrentDatabase() async {
    if (!IsarCore.kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      Isar.deleteDatabase(name: _dbName, directory: dir.path);
    }
  }
}
