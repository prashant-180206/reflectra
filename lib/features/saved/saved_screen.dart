import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pattern_box/pattern_box.dart';
import 'package:reflectra/core/database/db_service.dart';
import 'package:reflectra/core/routes/app_routes.dart';
import 'package:reflectra/features/saved/riverpod/saved_controller.dart';
import 'package:reflectra/features/saved/widgets/hearder.dart';
import 'package:reflectra/features/saved/widgets/pagination_bar.dart';
import 'package:reflectra/features/saved/widgets/saved_list_item.dart';

class SavedScreen extends HookConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(savedControllerProvider);
    final notifier = ref.read(savedControllerProvider.notifier);
    final showFilters = useState(false);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Entries')),
      body: PatternBoxWidget(
        pattern: WavePainter(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading entries: $e')),
            data: (state) {
              /// Build month labels
              final monthLabels = _buildMonthLabels(
                context,
                notifier.monthKeys(),
              );

              final paged = notifier.pagedEntries();
              final filteredCount = notifier.filteredCount();
              final totalPages = notifier.totalPages();

              return Column(
                children: [
                  /// FILTER HEADER + CONTENT
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        FilterHeader(
                          showFilters: showFilters.value,
                          onToggle: () =>
                              showFilters.value = !showFilters.value,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: showFilters.value
                              ? FilterPanel(
                                  state: state,
                                  monthLabels: monthLabels,
                                  notifier: notifier,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  /// LIST SECTION
                  Expanded(
                    child: paged.isEmpty
                        ? Center(
                            child: Text(
                              'No entries found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: paged.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = paged[index];
                              return SavedListItem(
                                entry: entry,
                                onTap: () async {
                                  await EntryViewerRoute(
                                    entryId: entry.id,
                                  ).push(context);
                                  notifier.refresh();
                                },
                                onDelete: () async {
                                  await DbService.deleteEntry(entry.id);
                                  notifier.refresh();
                                },
                              );
                            },
                          ),
                  ),

                  /// PAGINATION
                  PaginationBar(
                    currentPage: state.pageIndex,
                    totalPages: totalPages,
                    totalItems: filteredCount,
                    canGoPrev: notifier.canGoPrev,
                    canGoNext: notifier.canGoNext,
                    onPrevious: notifier.prevPage,
                    onNext: notifier.nextPage,
                    onFirst: notifier.goToFirstPage,
                    onLast: notifier.goToLastPage,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Helper: Build Month Labels
  List<String> _buildMonthLabels(BuildContext context, List<String> monthKeys) {
    final labels = <String>['All'];

    for (final key in monthKeys) {
      final parts = key.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final dt = DateTime(y, m);

      labels.add(MaterialLocalizations.of(context).formatMonthYear(dt));
    }

    return labels;
  }
}

