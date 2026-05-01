import 'package:reflectra/core/database/crud/entry_db.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_entry_provider.g.dart';

@riverpod
FutureOr<DiaryEntry?> activeEntry(Ref ref, int id) async {
  return EntryDb.getEntryById(id);
}
