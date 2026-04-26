import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindlog/core/routes/app_routes.dart';
import 'package:mindlog/core/theme/riverpod/theme_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindLog'),
        actions: [
          IconButton(
            onPressed: () => ref.read(appThemeProvider.notifier).toggle(),
            icon: const Icon(Icons.light_mode_outlined),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Journal Dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Keep multiple entries per day and use AI to turn chats into structured diary notes.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: Text('Get to Chat about today'),
              onPressed: () {
                DailyChatRoute().push(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
