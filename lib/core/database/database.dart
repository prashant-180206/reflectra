import 'package:isar_plus/isar_plus.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:path_provider/path_provider.dart';

class Database {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = Isar.open(
      schemas: [DiaryEntrySchema],
      directory: dir.path, // Optional: specify a custom directory
    );
  }
}
