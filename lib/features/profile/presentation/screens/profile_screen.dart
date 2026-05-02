import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pattern_box/pattern_box.dart';
import 'package:reflectra/core/routes/app_routes.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: PatternBoxWidget(
        pattern: CircularPainter(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Row(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                child: Icon(Icons.badge_outlined),
                              ),

                              Text(
                                'Persona ',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text(
                            'View and update the persona that shapes the app experience.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Open the persona editor to review the stored profile and update it as needed.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          const PersonaViewerEditorRoute().push(context);
                        },
                        icon: const Icon(Icons.open_in_new_outlined),
                        label: const Text('Open persona editor'),
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
                        'Instruction configuration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Set up the custom instructions used by daily chat.',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          const InstructionConfigurationRoute().push(context);
                        },
                        child: const Text('Open instructions'),
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
      ),
    );
  }
}
