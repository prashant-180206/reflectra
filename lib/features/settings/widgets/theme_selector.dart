import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reflectra/core/theme/riverpod/theme_provider.dart';

class ThemeSelector extends HookConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeAsync = ref.watch(appColorSchemeProvider);
    final themeSetter = ref.read(appColorSchemeProvider.notifier);

    // Safely get the value from the AsyncValue
    final selectedScheme = currentThemeAsync.value ?? FlexScheme.materialBaseline;

    return DropdownButton<FlexScheme>(
      value: selectedScheme,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.palette_outlined),
      selectedItemBuilder: (BuildContext context) {
        return FlexScheme.values.map((FlexScheme scheme) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _formatName(scheme.name),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }).toList();
      },
      items: FlexScheme.values.map((scheme) {
        // FIX: Use '??' instead of '!' to prevent null pointer errors
        // If a scheme is missing, it falls back to the default Material colors
        final schemeData = FlexColor.schemes[scheme] ?? FlexColor.schemes[FlexScheme.materialBaseline]!;
        final colors = schemeData.light;

        return DropdownMenuItem(
          value: scheme,
          child: Row(
            children: [
              _ColorStack(primary: colors.primary, secondary: colors.secondary),
              const SizedBox(width: 12),
              Text(_formatName(scheme.name)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          themeSetter.setScheme(value);
        }
      },
    );
  }

  // Helper to make enum names look pretty (e.g. mandyRed -> Mandy Red)
  String _formatName(String name) {
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'), 
      (match) => ' ${match.group(0)}'
    );
    return result[0].toUpperCase() + result.substring(1);
  }
}

class _ColorStack extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const _ColorStack({required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 20,
      child: Stack(
        children: [
          _Circle(color: primary, left: 0),
          _Circle(color: secondary, left: 12),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final Color color;
  final double left;
  const _Circle({required this.color, required this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).cardColor, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))
          ],
        ),
      ),
    );
  }
}