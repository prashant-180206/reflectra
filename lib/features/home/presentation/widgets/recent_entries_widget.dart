import 'package:flutter/material.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:reflectra/core/database/utils/db_utils.dart';

/// Widget to display recent diary entries
class RecentEntriesSection extends StatelessWidget {
  final List<DiaryEntry> entries;
  final VoidCallback? onViewAll;
  final Function(int)? onEntryTap;

  const RecentEntriesSection({
    super.key,
    required this.entries,
    this.onViewAll,
    this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Entries',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 48,
                    color: theme.hintColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No entries yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final date =
                  DbUtils.dateFromDayKey(entry.dayKey);
              final dateFormatted =
                  MaterialLocalizations.of(context)
                      .formatShortDate(date);
              final timeFormatted =
                  TimeOfDay.fromDateTime(entry.createdAt)
                      .format(context);

              return Material(
                child: InkWell(
                  onTap: () => onEntryTap?.call(entry.id),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: entry.source == 'ai'
                                ? Colors.purple
                                : Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style:
                                    theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$dateFormatted • $timeFormatted',
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          entry.source == 'ai'
                              ? Icons.auto_awesome
                              : Icons.edit_note,
                          size: 18,
                          color: entry.source == 'ai'
                              ? Colors.purple
                              : Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String? actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onAction != null && actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
