import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Editor extends HookWidget {
  const Editor({
    super.key,
    required this.content,
    required this.editorState,
    this.editing = false,
  });

  final String content;
  final EditorState editorState;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final editorTextStyle = (textTheme.bodyMedium ?? const TextStyle())
        .copyWith(color: colorScheme.onSurface, fontSize: 16, height: 1.5);

    final editorScrollController = useMemoized(
      () => EditorScrollController(editorState: editorState),
      [editorState],
    );

    useEffect(() {
      return editorScrollController.dispose;
    }, [editorScrollController]);

    final floatingToolbarItems = useMemoized(
      () => <ToolbarItem>[
        ...headingItems,
        paragraphItem,
        ...markdownFormatItems,
        bulletedListItem,
        numberedListItem,
        quoteItem,
        linkItem,
        buildTextColorItem(),
        buildHighlightColorItem(),
      ],
      const [],
    );

    final mobileToolbarItems = useMemoized(
      () => <MobileToolbarItem>[
        headingMobileToolbarItem,
        listMobileToolbarItem,
        quoteMobileToolbarItem,
        textDecorationMobileToolbarItemV2,
        buildTextAndBackgroundColorMobileToolbarItem(),
        linkMobileToolbarItem,
      ],
      const [],
    );

    final isMobileOS =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    Widget editor = AppFlowyEditor(
      editorState: editorState,
      editorScrollController: editorScrollController,
      editable: editing,
      editorStyle: EditorStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        cursorColor: colorScheme.primary,
        dragHandleColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.18),
        textStyleConfiguration: TextStyleConfiguration(
          text: editorTextStyle,
          bold: editorTextStyle.copyWith(fontWeight: FontWeight.w700),
          italic: editorTextStyle.copyWith(fontStyle: FontStyle.italic),
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
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        textSpanDecorator: defaultTextSpanDecoratorForAttribute,
      ),
    );

    if (isMobileOS) {
      editor = MobileToolbarV2(
        editorState: editorState,
        toolbarItems: mobileToolbarItems,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurfaceVariant,
        iconColor: colorScheme.onSurface,
        itemHighlightColor: colorScheme.primary,
        primaryColor: colorScheme.primary,
        onPrimaryColor: colorScheme.onPrimary,
        itemOutlineColor: colorScheme.outlineVariant,
        outlineColor: colorScheme.outlineVariant,
        child: editor,
      );
    } else {
      editor = FloatingToolbar(
        items: floatingToolbarItems,
        editorState: editorState,
        editorScrollController: editorScrollController,
        textDirection: Directionality.of(context),
        style: FloatingToolbarStyle(
          backgroundColor: colorScheme.inverseSurface,
          toolbarActiveColor: colorScheme.primary,
          toolbarIconColor: colorScheme.onInverseSurface,
          toolbarShadowColor: colorScheme.shadow,
          toolbarElevation: 4,
        ),
        child: editor,
      );
    }

    return editor;
  }
}
