import 'package:isar_plus/isar_plus.dart';
import 'package:reflectra/core/database/database.dart';
import 'package:reflectra/core/database/models/custom_instruction.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:reflectra/core/database/models/persona.dart';
import 'package:reflectra/core/database/utils/db_utils.dart';

/// Consolidated database service combining all CRUD operations
class DbService {
  static Isar get _isar => Database.isar;

  // ==================== DIARY ENTRIES ====================
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

  static Future<List<DiaryEntry>> getLastThreeEntries() async {
    return _isar.diaryEntrys.where().sortByCreatedAtDesc().findAll(limit: 3);
  }

  static Future<List<DiaryEntry>> getAllEntries() async {
    return _isar.diaryEntrys.where().sortByCreatedAtDesc().findAll();
  }

  static Future<List<DiaryEntry>> getEntriesWithPagination({
    required int limit,
    required int offset,
  }) async {
    return _isar.diaryEntrys
        .where()
        .sortByCreatedAtDesc()
        .findAll(offset: offset, limit: limit);
  }

  static Future<int> countEntries() async {
    return _isar.diaryEntrys.where().count();
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

  static Future<int> getEntriesCountByMonth(int year, int month) async {
    final entries = await getAllEntries();
    return entries
        .where((e) {
          final date = DbUtils.dateFromDayKey(e.dayKey);
          return date.year == year && date.month == month;
        })
        .length;
  }

  static Future<int> getEntriesCountByDay(DateTime date) async {
    final dayKey = DbUtils.dayKeyFromDate(date);
    return _isar.diaryEntrys.where().dayKeyEqualTo(dayKey).count();
  }

  // ==================== PERSONA ====================
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

  static Future<bool> hasPersona() async {
    return  _isar.personas.get(0) != null;
  }

  // ==================== CUSTOM INSTRUCTIONS ====================
  static Future<CustomInstruction?> getCustomInstruction() async {
    return _isar.customInstructions.get(0);
  }

  static Future<void> saveCustomInstruction(String instructions) async {
    await _isar.write((isar) {
      final ci = CustomInstruction(id: 0, instructions: instructions);
      isar.customInstructions.put(ci);
    });
  }

  static Future<bool> deleteCustomInstruction() async {
    return await _isar.write((isar) {
      return isar.customInstructions.delete(0);
    });
  }

  static Future<bool> hasCustomInstruction() async {
    return  _isar.customInstructions.get(0) != null;
  }

  // ==================== STATISTICS ====================
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final totalEntries = await countEntries();
    final lastThreeEntries = await getLastThreeEntries();
    final todayEntries =
        await getEntriesCountByDay(DateTime.now());
    final hasPersona = await DbService.getPersona() != null;
    final hasCustomInstructions =
        await DbService.getCustomInstruction() != null;

    return {
      'totalEntries': totalEntries,
      'lastThreeEntries': lastThreeEntries,
      'todayEntries': todayEntries,
      'hasPersona': hasPersona,
      'hasCustomInstructions': hasCustomInstructions,
    };
  }

  // ==================== UTILITY ====================
  static Future<void> resetDatabase() async {
    if (!IsarCore.kIsWeb) {
      await Database.resetCurrentDatabase();
    }
  }
}
