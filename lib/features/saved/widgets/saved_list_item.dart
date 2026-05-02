import 'package:flutter/material.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:reflectra/core/database/utils/db_utils.dart';

class SavedListItem extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SavedListItem({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dayText = MaterialLocalizations.of(
      context,
    ).formatShortDate(DbUtils.dateFromDayKey(entry.dayKey));
    final timeText = TimeOfDay.fromDateTime(entry.createdAt).format(context);

    final txttheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        leading: Icon(
          entry.source == 'ai' ? Icons.auto_awesome : Icons.edit_note,
        ),
        title: Text(entry.title, style: txttheme.titleMedium),
        subtitle: Text('$dayText $timeText', style: txttheme.labelMedium),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete Entry',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
