import 'package:isar_plus/isar_plus.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:path_provider/path_provider.dart';

class Database {
  static late Isar isar;
  static const String _dbName = 'mindlog_diary_v2';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = Isar.open(
      schemas: [DiaryEntrySchema],
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

  static int dayKeyFromDate(DateTime date) {
    return (date.year * 10000) + (date.month * 100) + date.day;
  }

  static DateTime dateFromDayKey(int dayKey) {
    final year = dayKey ~/ 10000;
    final month = (dayKey % 10000) ~/ 100;
    final day = dayKey % 100;
    return DateTime(year, month, day);
  }

  static Future<List<DiaryEntry>> getEntriesForDay(DateTime date) async {
    final dayKey = dayKeyFromDate(date);
    return isar.diaryEntrys
        .where()
        .dayKeyEqualTo(dayKey)
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<DiaryEntry?> getEntryById(int id) async {
    return isar.diaryEntrys.get(id);
  }

  static Future<int> saveEntry(DiaryEntry entry) async {
    entry.updatedAt = DateTime.now();
    return isar.write((isar) {
      if (entry.id <= 0) {
        entry.id = isar.diaryEntrys.autoIncrement();
      }
      isar.diaryEntrys.put(entry);
      return entry.id;
    });
  }

  static Future<bool> deleteEntry(int id) async {
    return isar.write((isar) {
      return isar.diaryEntrys.delete(id);
    });
  }
}
