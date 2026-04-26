import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindlog/core/routes/app_routes.dart';
import 'package:mindlog/features/entry/data/riverpod/active_entry_provider.dart';

class EntryViewerScreen extends HookConsumerWidget {
  const EntryViewerScreen({super.key, required this.entryId});

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(activeEntryProvider(entryId));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final editorTextStyle = (textTheme.bodyMedium ?? const TextStyle())
        .copyWith(color: colorScheme.onSurface, fontSize: 16, height: 1.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Entry',
            onPressed: () async {
              await EntryEditorRoute(entryId: entryId).push(context);
              // ref.refresh(activeEntryProvider(entryId));
            },
          ),
        ],
      ),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),

        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Entry not found'));
          }

          final editorState = useMemoized(
            () => EditorState(document: markdownToDocument(entry.content)),
            [entry.id],
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppFlowyEditor(
                      editorState: editorState,
                      editable: false,
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
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        textSpanDecorator: defaultTextSpanDecoratorForAttribute,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
