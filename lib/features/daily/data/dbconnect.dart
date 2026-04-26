import 'package:mindlog/core/database/crud/entry_db.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:mindlog/core/database/utils/db_utils.dart';
import 'package:mindlog/core/utils/md.dart';

Future<int> saveDiaryEntry(String content) async {
  final dayKey = DbUtils.dayKeyFromDate(DateTime.now());
  final newEntry = DiaryEntry(
    dayKey: dayKey,
    createdAt: DateTime.now(),
    title: MdUtils.extractTitle(content),
    content: content,
    source: 'ai',
  );
  final savedid = await EntryDb.saveEntry(newEntry);
  return savedid;
}
