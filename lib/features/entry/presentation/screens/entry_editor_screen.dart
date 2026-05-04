import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reflectra/core/database/models/diary_entry.dart';
import 'package:reflectra/core/routes/app_routes.dart';
import 'package:reflectra/features/entry/data/dbconnect.dart';
import 'package:reflectra/features/entry/data/riverpod/active_entry_provider.dart';
import 'package:reflectra/core/widgets/editor.dart';

class EntryEditorScreen extends HookConsumerWidget {
  const EntryEditorScreen({super.key, required this.entryId});

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(activeEntryProvider(entryId));

    final saving = useState(false);
    final titleController = useTextEditingController();

    Future<void> saveEntry(EditorState editorState, DiaryEntry original) async {
      if (saving.value) return;

      final content = documentToMarkdown(editorState.document).trim();

      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content cannot be empty.')),
        );
        return;
      }

      final titleInput = titleController.text.trim();

      saving.value = true;
      await editDiaryEntry(content, titleInput, original);
      saving.value = false;

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry saved locally.')));
      HomeRoute().go(context);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Entry')),
        body: entryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (err, _) => Center(child: Text('Error: $err')),

          data: (entry) {
            if (entry == null) {
              return const Center(child: Text('Entry not found'));
            }
            final editorState = useMemoized(
              () => EditorState(document: markdownToDocument(entry.content)),
              [entry.content],
            );
            useEffect(() {
              titleController.text = entry.title;
              return null;
            }, [entry.id]);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Optional title',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Editor(
                        content: entry.content,
                        editorState: editorState,
                        editing: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving.value
                          ? null
                          : () => saveEntry(editorState, entry),
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
            );
          },
        ),
      ),
    );
  }
}
