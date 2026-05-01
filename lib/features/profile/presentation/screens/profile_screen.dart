import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reflectra/core/database/crud/custom_instruction_db.dart';
import 'package:reflectra/core/routes/app_routes.dart';
import 'package:reflectra/core/singleton.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructionsController = useTextEditingController();
    final isLoading = useState(true);
    final isSaving = useState(false);

    useEffect(() {
      Future<void> loadInstructions() async {
        try {
          final stored = await CustomInstructionDb.getCustomInstruction();
          instructionsController.text = stored?.instructions ?? '';
        } catch (e) {
          logger.e('Failed to load custom instructions: $e');
        } finally {
          isLoading.value = false;
        }
      }

      loadInstructions();
      return null;
    }, [instructionsController]);

    Future<void> saveInstructions() async {
      if (isSaving.value) {
        return;
      }

      isSaving.value = true;

      try {
        await CustomInstructionDb.saveCustomInstruction(
          instructionsController.text.trim(),
        );

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom instructions saved.')),
        );
      } catch (e) {
        logger.e('Failed to save custom instructions: $e');

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save custom instructions.')),
        );
      } finally {
        isSaving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person_outline),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom chat instructions',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'These instructions are added to daily chat so replies can match your preferences.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isLoading.value)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      TextField(
                        controller: instructionsController,
                        minLines: 6,
                        maxLines: 12,
                        decoration: const InputDecoration(
                          labelText: 'Custom instructions',
                          alignLabelWithHint: true,
                          hintText:
                              'For example: keep replies concise, use a calm tone, ask follow-up questions only when needed.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Leave this empty if you want the daily chat to use only persona and diary context.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: isLoading.value || isSaving.value
                          ? null
                          : saveInstructions,
                      icon: isSaving.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save instructions'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Persona builder',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If you want the app to learn your preferences, create or update your persona here.',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        PersonaMakingChatRoute().push(context);
                      },
                      child: const Text('Create Persona'),
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
