import 'package:isar_plus/isar_plus.dart';

part 'diary_entry.g.dart';

@collection
class DiaryEntry {
  DiaryEntry({required this.id});
  final int id ;
  late String name;

  int? age;

  late String email;
}