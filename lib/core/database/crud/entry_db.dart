import 'package:isar_plus/isar_plus.dart';
import 'package:mindlog/core/database/database.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:mindlog/core/database/utils/db_utils.dart';

class EntryDb {
  
  static Isar get _isar => Database.isar;

  static Future<List<DiaryEntry>> getEntriesForDay(DateTime date) async {
    final dayKey = DbUtils.dayKeyFromDate(date);
    return _isar.diaryEntrys
        .where()
        .dayKeyEqualTo(dayKey)
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<DiaryEntry?> getEntryById(int id) async {
    return _isar.diaryEntrys.get(id);
  }

  static Future<int> saveEntry(DiaryEntry entry) async {
    entry.updatedAt = DateTime.now();
    return _isar.write((isar) {
      if (entry.id <= 0) {
        entry.id = isar.diaryEntrys.autoIncrement();
      }
      isar.diaryEntrys.put(entry);
      return entry.id;
    });
  }

  static Future<bool> deleteEntry(int id) async {
    return _isar.write((isar) {
      return isar.diaryEntrys.delete(id);
    });
  }
}
