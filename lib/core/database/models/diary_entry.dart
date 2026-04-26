import 'package:isar_plus/isar_plus.dart';

part 'diary_entry.g.dart';

@collection
class DiaryEntry {
  DiaryEntry({
    this.id = 0,
    required this.dayKey,
    required this.createdAt,
    required this.title,
    required this.content,
    DateTime? updatedAt,
    this.source = 'manual',
  });

  int id;

  @Index()
  late int dayKey;

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;

  late String title;

  late String content;

  late String source;
}