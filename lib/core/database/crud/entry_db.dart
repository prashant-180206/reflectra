import 'package:reflectra/core/database/db_service.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';

/// Deprecated: Use DbService instead for new code.
/// This class maintains backwards compatibility.
class EntryDb {
  static Future<List<DiaryEntry>> getEntriesForDay(DateTime date) =>
      DbService.getEntriesForDay(date);

  static Future<DiaryEntry?> getEntryById(int id) =>
      DbService.getEntryById(id);

  static Future<List<DiaryEntry>> getLastThreeEntries() =>
      DbService.getLastThreeEntries();

  static Future<int> saveEntry(DiaryEntry entry) =>
      DbService.saveEntry(entry);

  static Future<bool> deleteEntry(int id) =>
      DbService.deleteEntry(id);

  static Future<List<DiaryEntry>> getAllEntries() =>
      DbService.getAllEntries();
}
