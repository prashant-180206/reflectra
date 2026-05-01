import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:reflectra/core/database/crud/entry_db.dart';
import 'package:reflectra/core/database/database.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:reflectra/core/database/utils/db_utils.dart';
import 'package:reflectra/core/routes/app_routes.dart';

class SavedScreen extends HookWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final refreshCounter = useState(0);

    Future<List<DiaryEntry>> entriesFuture() async {
      return Database.isar.diaryEntrys.where().sortByCreatedAtDesc().findAll();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Entries')),
      body: SafeArea(
        child: FutureBuilder<List<DiaryEntry>>(
          key: ValueKey(refreshCounter.value),
          future: entriesFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = snapshot.data ?? const <DiaryEntry>[];
            if (entries.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No saved entries yet.'),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final dayText = MaterialLocalizations.of(
                  context,
                ).formatShortDate(DbUtils.dateFromDayKey(entry.dayKey));

                return Card(
                  child: ListTile(
                    leading: Icon(
                      entry.source == 'ai' ? Icons.auto_awesome : Icons.edit_note,
                    ),
                    title: Text(entry.title),
                    subtitle: Text(
                      '$dayText\n${entry.content}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    onTap: () async {
                      await EntryViewerRoute(entryId: entry.id).push(context);
                      refreshCounter.value++;
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete Entry',
                      onPressed: () async {
                        await EntryDb.deleteEntry(entry.id);
                        refreshCounter.value++;
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
