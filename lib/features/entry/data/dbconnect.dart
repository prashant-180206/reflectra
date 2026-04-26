import 'package:mindlog/core/database/crud/entry_db.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';

Future<int> editDiaryEntry(
  String content,
  String titleInput,
  DiaryEntry original,
) async {
  final firstLine = content
      .split('\n')
      .first
      .trim()
      .replaceFirst(RegExp(r'^#+\s*'), '');

  final title = titleInput.isEmpty
      ? firstLine.substring(0, firstLine.length > 48 ? 48 : firstLine.length)
      : titleInput;

  final id = await EntryDb.saveEntry(
    DiaryEntry(
      id: original.id,
      dayKey: original.dayKey,
      createdAt: original.createdAt,
      title: title,
      content: content,
      source: original.source,
      updatedAt: DateTime.now(),
    ),
  );

  return id;
}
