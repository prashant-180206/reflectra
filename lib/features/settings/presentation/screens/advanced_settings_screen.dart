import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reflectra/core/security/apikeystore.dart';
import 'package:reflectra/core/security/model_name_store.dart';
import 'package:reflectra/features/settings/data/riverpod/models_provider.dart';

class AdvancedSettingsScreen extends HookConsumerWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance & AI')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ByokCard(),
            SizedBox(height: 12),
            ModelSelectionCard(),
          ],
        ),
      ),
    );
  }
}

class ByokCard extends HookConsumerWidget {
  const ByokCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshCounter = useState(0);
    final keyController = useTextEditingController();

    Future<void> loadKey() async {
      keyController.text = await Apikeystore.getKey() ?? '';
    }

    useEffect(() {
      loadKey();
      return null;
    }, [refreshCounter.value]);

    Future<bool> apiKeyFuture() {
      return Apikeystore.hasKey();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BYOK: API Key',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Configure your Ollama key for AI daily chat.'),
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

            TextField(
              controller: keyController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Paste your Ollama Cloud key',
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    await Apikeystore.deleteKey();
                    keyController.clear();
                    await ref.read(aiModelsProvider.notifier).refresh();
                    refreshCounter.value++;
                  },
                  child: const Text('Remove'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    await Apikeystore.setKey(keyController.text.trim());
                    await ref.read(aiModelsProvider.notifier).refresh();
                    refreshCounter.value++;
                  },
                  child: const Text('Save Key'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ModelSelectionCard extends HookConsumerWidget {
  const ModelSelectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(aiModelsProvider);
    final refreshCounter = useState(0);
    final selectedModel = useState<String?>(null);

    Future<void> loadCurrentModel() async {
      final model = await ModelNameStore.getModelName();
      selectedModel.value = model;
    }

    useEffect(() {
      loadCurrentModel();
      return null;
    }, [refreshCounter.value]);

    Future<void> saveModel(String model) async {
      await ModelNameStore.setModelName(model);
      selectedModel.value = model;
      refreshCounter.value++;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Model Selection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Select and save your preferred Ollama model.'),
            const SizedBox(height: 12),
            models.when(
              loading: () => const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to load models: ${e.toString()}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              data: (data) {
                if (data.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No models available'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedModel.value != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Current: ${selectedModel.value}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedModel.value,
                      hint: const Text('Select a model'),
                      items: data
                          .map(
                            (model) => DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newModel) {
                        if (newModel != null) {
                          saveModel(newModel);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
