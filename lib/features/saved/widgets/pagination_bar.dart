import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFirst;
  final VoidCallback onLast;
  final ValueChanged<int>? onPageSelected;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onFirst,
    required this.onLast,
    this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'First',
              onPressed: canGoPrev ? onFirst : null,
              icon: const Icon(Icons.first_page, size: 20),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              tooltip: 'Previous',
              onPressed: canGoPrev ? onPrevious : null,
              icon: const Icon(Icons.chevron_left, size: 20),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
            ),

            const SizedBox(width: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${currentPage + 1} / $totalPages',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              tooltip: 'Next',
              onPressed: canGoNext ? onNext : null,
              icon: const Icon(Icons.chevron_right, size: 20),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              tooltip: 'Last',
              onPressed: canGoNext ? onLast : null,
              icon: const Icon(Icons.last_page, size: 20),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
            ),

            const SizedBox(width: 12),

            Text(
              '$totalItems items',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}