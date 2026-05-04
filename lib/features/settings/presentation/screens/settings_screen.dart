import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reflectra/core/routes/app_routes.dart';
import 'package:reflectra/core/theme/riverpod/theme_provider.dart';
import 'package:reflectra/features/settings/widgets/theme_selector.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ThemeSelector(),
            SizedBox(height: 12),
            ThemeCard(),
            SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('AI Settings', style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'API key, and model selection',
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  AiSettingsRoute().push(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeCard extends HookConsumerWidget {
  const ThemeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text('Switch between light and dark mode.'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () => ref.read(appThemeProvider.notifier).toggle(),
              icon: const Icon(Icons.light_mode_outlined),
              label: const Text('Toggle'),
            ),
          ],
        ),
      ),
    );
  }
}
