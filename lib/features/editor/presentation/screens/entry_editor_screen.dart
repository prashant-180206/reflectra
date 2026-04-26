import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mindlog/core/database/database.dart';
import 'package:mindlog/core/database/models/diary_entry.dart';
import 'package:mindlog/core/singleton.dart';

class EntryEditorScreen extends HookWidget {
  const EntryEditorScreen({super.key, this.entryId, this.dayKey});

  final int? entryId;
  final int? dayKey;

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final saving = useState(false);
    final currentEntryId = useState<int?>(entryId);
    final selectedDate = useState(
      Database.dateFromDayKey(
        dayKey ?? Database.dayKeyFromDate(DateTime.now()),
      ),
    );
    final titleController = useTextEditingController();
    final editorState = useState<EditorState?>(null);

    useEffect(() {
      Future<void> loadExisting() async {
        logger.d(
          'Loading entry for editing, entryId: $entryId, dayKey: $dayKey',
        );
        if (entryId == null) {
          editorState.value = EditorState(document: markdownToDocument(''));
          loading.value = false;
          return;
        }

        logger.d('Fetching entry with ID: $entryId from database');

        final entry = await Database.getEntryById(entryId!);
        logger.d('Loaded entry for editing: ${entry?.content}');
        if (entry == null) {
          editorState.value = EditorState(document: markdownToDocument(''));
          loading.value = false;
          return;
        }

        currentEntryId.value = entry.id;
        selectedDate.value = Database.dateFromDayKey(entry.dayKey);
        titleController.text = entry.title;
        editorState.value = EditorState(
          document: markdownToDocument(entry.content),
        );
        loading.value = false;
      }

      logger.d('Existing entry loaded.');

      loadExisting();
      return null;
    }, [entryId]);

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        selectedDate.value = picked;
      }
    }

    Future<void> saveEntry() async {
      if (saving.value || editorState.value == null) {
        return;
      }

      final content = documentToMarkdown(editorState.value!.document).trim();
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content cannot be empty.')),
        );
        return;
      }

      final titleInput = titleController.text.trim();
      final firstLine = content
          .split('\n')
          .first
          .trim()
          .replaceFirst(RegExp(r'^#+\s*'), '');
      final title = titleInput.isEmpty
          ? firstLine.substring(
              0,
              firstLine.length > 48 ? 48 : firstLine.length,
            )
          : titleInput;

      saving.value = true;
      final entry = DiaryEntry(
        id: currentEntryId.value ?? 0,
        dayKey: Database.dayKeyFromDate(selectedDate.value),
        createdAt: DateTime.now(),
        title: title,
        content: content,
        source: 'manual',
      );
      final savedId = await Database.saveEntry(entry);
      currentEntryId.value = savedId;
      saving.value = false;

      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry saved locally.')));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final editorTextStyle = (textTheme.bodyMedium ?? const TextStyle())
        .copyWith(color: colorScheme.onSurface, fontSize: 16, height: 1.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Editor'),
        actions: [
          IconButton(
            onPressed: saveEntry,
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Entry',
          ),
        ],
      ),
      body: loading.value || editorState.value == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_note_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          MaterialLocalizations.of(
                            context,
                          ).formatFullDate(selectedDate.value),
                        ),
                      ),
                      TextButton(
                        onPressed: pickDate,
                        child: const Text('Change Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Optional title for this entry',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppFlowyEditor(
                        editorState: editorState.value!,
                        editable: true,
                        editorStyle: EditorStyle(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          cursorColor: colorScheme.primary,
                          dragHandleColor: colorScheme.primary,
                          selectionColor: colorScheme.primary.withValues(
                            alpha: 0.18,
                          ),
                          textStyleConfiguration: TextStyleConfiguration(
                            text: editorTextStyle,
                            bold: editorTextStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            italic: editorTextStyle.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            underline: editorTextStyle.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                            strikethrough: editorTextStyle.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                            href: editorTextStyle.copyWith(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            code: editorTextStyle.copyWith(
                              fontFamily: 'monospace',
                              color: colorScheme.onSurface,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          textSpanDecorator:
                              defaultTextSpanDecoratorForAttribute,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving.value ? null : saveEntry,
                      icon: saving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(saving.value ? 'Saving...' : 'Save Entry'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
