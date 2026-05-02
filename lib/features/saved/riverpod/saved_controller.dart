import 'dart:async';

import 'package:reflectra/core/database/db_service.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:reflectra/core/database/utils/db_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_controller.g.dart';

class SavedState {
  final List<DiaryEntry> entries;
  final String selectedMonthLabel; // display label like 'All' or 'January 2024'
  final int pageSize;
  final int pageIndex;

  SavedState({
    required this.entries,
    required this.selectedMonthLabel,
    required this.pageSize,
    required this.pageIndex,
  });

  SavedState copyWith({
    List<DiaryEntry>? entries,
    String? selectedMonthLabel,
    int? pageSize,
    int? pageIndex,
  }) {
    return SavedState(
      entries: entries ?? this.entries,
      selectedMonthLabel: selectedMonthLabel ?? this.selectedMonthLabel,
      pageSize: pageSize ?? this.pageSize,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}

@riverpod
class SavedController extends _$SavedController {
  @override
  FutureOr<SavedState> build() async {
    final list = await DbService.getAllEntries();
    return SavedState(entries: list, selectedMonthLabel: 'All', pageSize: 10, pageIndex: 0);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await DbService.getAllEntries();
      return SavedState(entries: list, selectedMonthLabel: 'All', pageSize: 10, pageIndex: 0);
    });
  }

  void setMonthLabel(String label) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(selectedMonthLabel: label, pageIndex: 0));
  }

  void setPageSize(int size) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(pageSize: size, pageIndex: 0));
  }

  void setPageIndex(int idx) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(pageIndex: idx));
  }

  // Helpers to compute derived views
  List<String> monthKeys() {
    final current = state.asData?.value;
    if (current == null) return [];
    final set = <String>{};
    for (final e in current.entries) {
      final dt = DbUtils.dateFromDayKey(e.dayKey);
      set.add('${dt.year}-${dt.month.toString().padLeft(2, '0')}');
    }
    final keys = set.toList()..sort((a, b) => b.compareTo(a));
    return keys;
  }

  List<DiaryEntry> filteredEntries() {
    final current = state.asData?.value;
    if (current == null) return [];
    if (current.selectedMonthLabel == 'All') return current.entries;
    try {
      final parts = current.selectedMonthLabel.split(' ');
      final monthName = parts.first;
      final year = int.parse(parts.last);
      final month = _monthNumber(monthName);
      return current.entries.where((e) {
        final dt = DbUtils.dateFromDayKey(e.dayKey);
        return dt.year == year && dt.month == month;
      }).toList();
    } catch (_) {
      return current.entries;
    }
  }

  List<DiaryEntry> pagedEntries() {
    final filtered = filteredEntries();
    final current = state.asData?.value;
    if (current == null) return [];
    final total = filtered.length;
    final perPage = current.pageSize;
    final totalPages = (total / perPage).ceil().clamp(1, 999999);
    final idx = current.pageIndex.clamp(0, totalPages - 1);
    final start = idx * perPage;
    return filtered.skip(start).take(perPage).toList();
  }

  int totalPages() {
    final filtered = filteredEntries();
    final current = state.asData?.value;
    if (current == null) return 1;
    final perPage = current.pageSize;
    return (filtered.length / perPage).ceil().clamp(1, 999999);
  }

  int filteredCount() {
    return filteredEntries().length;
  }

  bool get canGoNext {
    final current = state.asData?.value;
    if (current == null) return false;
    return current.pageIndex < totalPages() - 1;
  }

  bool get canGoPrev {
    final current = state.asData?.value;
    if (current == null) return false;
    return current.pageIndex > 0;
  }

  void goToFirstPage() {
    setPageIndex(0);
  }

  void goToLastPage() {
    setPageIndex(totalPages() - 1);
  }

  void nextPage() {
    if (canGoNext) {
      final current = state.asData?.value;
      if (current != null) {
        setPageIndex(current.pageIndex + 1);
      }
    }
  }

  void prevPage() {
    if (canGoPrev) {
      final current = state.asData?.value;
      if (current != null) {
        setPageIndex(current.pageIndex - 1);
      }
    }
  }
}

int _monthNumber(String monthName) {
  switch (monthName.toLowerCase()) {
    case 'january':
      return 1;
    case 'february':
      return 2;
    case 'march':
      return 3;
    case 'april':
      return 4;
    case 'may':
      return 5;
    case 'june':
      return 6;
    case 'july':
      return 7;
    case 'august':
      return 8;
    case 'september':
      return 9;
    case 'october':
      return 10;
    case 'november':
      return 11;
    case 'december':
      return 12;
    default:
      return 1;
  }
}
