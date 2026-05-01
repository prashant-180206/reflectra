import 'package:isar_plus/isar_plus.dart';

part 'custom_instruction.g.dart';

@collection
class CustomInstruction {
  CustomInstruction({this.id = 0, this.instructions = ''});
  int id;
  String instructions;
}
