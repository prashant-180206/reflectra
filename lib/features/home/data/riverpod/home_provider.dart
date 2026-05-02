import 'package:reflectra/core/database/db_service.dart';
import 'package:reflectra/core/database/models/custom_instruction.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:reflectra/core/database/models/persona.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_provider.g.dart';

/// Provider for getting today's diary entries count
@riverpod
Future<int> todayEntriesCount(Ref ref) async {
  return DbService.getEntriesCountByDay(DateTime.now());
}

/// Provider for getting total diary entries count
@riverpod
Future<int> totalEntriesCount(Ref ref) async {
  return DbService.countEntries();
}

/// Provider for getting last 3 diary entries
@riverpod
Future<List<DiaryEntry>> lastThreeEntries(Ref ref) async {
  return DbService.getLastThreeEntries();
}

/// Provider for getting user persona
@riverpod
Future<Persona?> userPersona(Ref ref) async {
  return DbService.getPersona();
}

/// Provider for getting custom instructions
@riverpod
Future<CustomInstruction?> customInstructions(Ref ref) async {
  return DbService.getCustomInstruction();
}

/// Provider for checking if persona is set up
@riverpod
Future<bool> isPersonaConfigured(Ref ref) async {
  return DbService.hasPersona();
}

/// Provider for checking if custom instructions are set
@riverpod
Future<bool> isCustomInstructionsSet(Ref ref) async {
  return DbService.hasCustomInstruction();
}

/// Combined dashboard stats provider
@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  final todayCount = await ref.watch(todayEntriesCountProvider.future);
  final totalCount = await ref.watch(totalEntriesCountProvider.future);
  final lastThree = await ref.watch(lastThreeEntriesProvider.future);
  final personaConfigured = await ref.watch(isPersonaConfiguredProvider.future);
  final instructionsSet = await ref.watch(isCustomInstructionsSetProvider.future);

  return DashboardStats(
    todayEntriesCount: todayCount,
    totalEntriesCount: totalCount,
    lastThreeEntries: lastThree,
    isPersonaConfigured: personaConfigured,
    isCustomInstructionsSet: instructionsSet,
  );
}

/// Model for dashboard statistics
class DashboardStats {
  final int todayEntriesCount;
  final int totalEntriesCount;
  final List<DiaryEntry> lastThreeEntries;
  final bool isPersonaConfigured;
  final bool isCustomInstructionsSet;

  DashboardStats({
    required this.todayEntriesCount,
    required this.totalEntriesCount,
    required this.lastThreeEntries,
    required this.isPersonaConfigured,
    required this.isCustomInstructionsSet,
  });
}
