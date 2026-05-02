import 'package:reflectra/core/database/db_service.dart';
import 'package:reflectra/core/database/models/custom_instruction.dart';

/// Deprecated: Use DbService instead for new code.
/// This class maintains backwards compatibility.
class CustomInstructionDb {
  static Future<CustomInstruction?> getCustomInstruction() =>
      DbService.getCustomInstruction();

  static Future<void> saveCustomInstruction(String instructions) =>
      DbService.saveCustomInstruction(instructions);

  static Future<bool> deleteCustomInstruction() =>
      DbService.deleteCustomInstruction();
}