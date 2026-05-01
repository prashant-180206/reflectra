import 'package:isar_plus/isar_plus.dart';
import 'package:reflectra/core/database/database.dart';
import 'package:reflectra/core/database/models/custom_instruction.dart';
import 'package:reflectra/core/singleton.dart';

class CustomInstructionDb {
  static Isar get _isar => Database.isar;

  static Future<CustomInstruction?> getCustomInstruction() async {
    return _isar.customInstructions.get(0);
  }

  static Future<void> saveCustomInstruction(String instructions) async {
    logger.d("Saving custom instruction: $instructions");
    await _isar.write((isar) {
      // Use the provided 'isar' instance inside the write transaction.
      final ci = CustomInstruction(id: 0, instructions: instructions);
      isar.customInstructions.put(ci);
    });
  }

  static Future<bool> deleteCustomInstruction() async {
    return await _isar.write((isar) {
      return isar.customInstructions.delete(0);
    });
  }
}