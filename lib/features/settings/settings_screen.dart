import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindlog/core/security/apikeystore.dart';
import 'package:mindlog/core/theme/riverpod/theme_provider.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    Future<bool> apiKeyFuture() {
      return Apikeystore.hasKey();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
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
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BYOK: API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configure your Ollama key for AI daily chat.',
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<bool>(
                      key: ValueKey(refreshCounter.value),
                      future: apiKeyFuture(),
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
                            Text(hasKey ? 'API key configured' : 'API key missing'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: openApiKeyDialog,
                      icon: const Icon(Icons.key_outlined),
                      label: const Text('Manage API Key'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
