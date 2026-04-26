import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindlog/core/database/database.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:mindlog/core/routes/app_routes.dart';
import 'package:mindlog/core/security/apikeystore.dart';
import 'package:mindlog/core/theme/riverpod/theme_provider.dart';

class LandingScreen extends HookConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final refreshCounter = useState(0);
    final keyController = useTextEditingController();

    Future<void> openApiKeyDialog() async {
      keyController.text = await Apikeystore.getKey() ?? '';
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('BYOK: Ollama API Key'),
            content: TextField(
              controller: keyController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Paste your Ollama Cloud key',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Apikeystore.deleteKey();
                  if (!dialogContext.mounted) {
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                  refreshCounter.value++;
                },
                child: const Text('Remove'),
              ),
              FilledButton(
                onPressed: () async {
                  await Apikeystore.setKey(keyController.text.trim());
                  if (!dialogContext.mounted) {
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                  refreshCounter.value++;
                },
                child: const Text('Save Key'),
              ),
            ],
          );
        },
      );
    }

    Future<List<DiaryEntry>> entriesFuture() {
      return Database.getEntriesForDay(selectedDate.value);
    }

    Future<bool> apiKeyFuture() {
      return Apikeystore.hasKey();
    }

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked == null) {
        return;
      }
      selectedDate.value = picked;
    }

    final dateText = MaterialLocalizations.of(
      context,
    ).formatFullDate(selectedDate.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindLog'),
        actions: [
          IconButton(
            onPressed: () => ref.read(appThemeProvider.notifier).toggle(),
            icon: const Icon(Icons.light_mode_outlined),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Journal Dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Keep multiple entries per day and use AI to turn chats into structured diary notes.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined),
                        const SizedBox(width: 8),
                        Expanded(child: Text(dateText)),
                        TextButton(
                          onPressed: pickDate,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () async {
                            await EntryEditorRoute(
                              dayKey: Database.dayKeyFromDate(
                                selectedDate.value,
                              ),
                            ).push(context);
                            refreshCounter.value++;
                          },
                          icon: const Icon(Icons.add_box_outlined),
                          label: const Text('New Entry'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await DailyChatRoute(
                              dayKey: Database.dayKeyFromDate(
                                selectedDate.value,
                              ),
                            ).push(context);
                            refreshCounter.value++;
                          },
                          icon: const Icon(Icons.psychology_alt_outlined),
                          label: const Text('AI Daily Chat'),
                        ),
                        OutlinedButton.icon(
                          onPressed: openApiKeyDialog,
                          icon: const Icon(Icons.key_outlined),
                          label: const Text('BYOK Settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<bool>(
                      future: apiKeyFuture(),
                      key: ValueKey(refreshCounter.value),
                      builder: (context, snapshot) {
                        final hasKey = snapshot.data == true;
                        return Row(
                          children: [
                            Icon(
                              hasKey ? Icons.verified : Icons.error_outline,
                              color: hasKey
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hasKey
                                  ? 'API key configured'
                                  : 'API key missing: configure BYOK before AI chat',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Entries on this date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FutureBuilder<List<DiaryEntry>>(
              key: ValueKey('${selectedDate.value.toIso8601String()}_${refreshCounter.value}'),
              future: entriesFuture(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ));
                }

                final entries = snapshot.data ?? const <DiaryEntry>[];
                if (entries.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No entries yet for this date. Start by creating one manually or via AI chat.'),
                    ),
                  );
                }

                return Column(
                  children: entries.map((entry) {
                    return Card(
                      child: ListTile(
                        title: Text(entry.title),
                        subtitle: Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Icon(
                          entry.source == 'ai' ? Icons.auto_awesome : Icons.edit_note,
                        ),
                        onTap: () async {
                          await EntryEditorRoute(
                            entryId: entry.id,
                            dayKey: entry.dayKey,
                          ).push(context);
                          refreshCounter.value++;
                        },
                        trailing: IconButton(
                          onPressed: () async {
                            await Database.deleteEntry(entry.id);
                            refreshCounter.value++;
                          },
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete Entry',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
