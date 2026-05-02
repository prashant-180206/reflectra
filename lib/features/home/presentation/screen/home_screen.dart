import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pattern_box/pattern_box.dart';
import 'package:reflectra/core/routes/app_routes.dart';
import 'package:reflectra/core/singleton.dart';
import 'package:reflectra/core/theme/riverpod/theme_provider.dart';
import 'package:reflectra/features/home/data/riverpod/home_provider.dart';
import 'package:reflectra/features/home/presentation/widgets/dashboard_widgets.dart';
import 'package:reflectra/features/home/presentation/widgets/recent_entries_widget.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 46,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            width: 100,
            height: 100,
          ),
        ),

        title: const Text('Reflectra'),

        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.read(appThemeProvider.notifier).toggle(),
            icon: const Icon(Icons.light_mode_outlined),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: PatternBoxWidget(
        pattern: WavePainter(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          // waveHeight: 20,
          // waveLength: 200,
        ),
        
        child: SafeArea(
          child: dashboardStatsAsync.when(
            loading: () => _buildLoadingState(context),
            error: (error, stackTrace) => _buildErrorState(context, error),
            data: (stats) => _buildDashboard(context, ref, stats),
          ),
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: List.generate(4, (_) => const StatCardSkeleton()),
        ),
      ],
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading dashboard',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build main dashboard
  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    DashboardStats stats,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome card
        _buildWelcomeCard(context, stats),
        const SizedBox(height: 24),

        // Statistics section
        Text(
          'Your Statistics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildStatsGrid(context, stats, ref),
        const SizedBox(height: 24),

        // Setup section
        Text(
          'Setup & Configuration',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildFeatureCards(context, stats),
        const SizedBox(height: 24),

        // Quick actions
        _buildQuickActions(context),
        const SizedBox(height: 24),

        // Recent entries
        if (stats.lastThreeEntries.isNotEmpty)
          RecentEntriesSection(
            entries: stats.lastThreeEntries,
            onViewAll: () => SavedRoute().push(context),
            onEntryTap: (entryId) async {
              await EntryViewerRoute(entryId: entryId).push(context);
              // Refresh dashboard
              final res = ref.refresh(dashboardStatsProvider);
              logger.d('Dashboard stats refreshed: $res');
            },
          ),
      ],
    );
  }

  /// Build welcome card
  Widget _buildWelcomeCard(BuildContext context, DashboardStats stats) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '🌅 Good Morning'
        : hour < 18
        ? '🌤️ Good Afternoon'
        : '🌙 Good Evening';

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.26),
              theme.primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have ${stats.todayEntriesCount} entries today. Keep reflecting!',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Build statistics grid
  Widget _buildStatsGrid(
    BuildContext context,
    DashboardStats stats,
    WidgetRef ref,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        StatCard(
          title: 'Today\'s Entries',
          value: stats.todayEntriesCount.toString(),
          icon: Icons.today,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onSecondary.withValues(alpha: 0.1),
          onTap: () => SavedRoute().push(context),
        ),
        StatCard(
          title: 'Total Entries',
          value: stats.totalEntriesCount.toString(),
          icon: Icons.library_books,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onTertiary.withValues(alpha: 0.1),
          onTap: () => SavedRoute().push(context),
        ),
        StatCard(
          title: 'Persona',
          value: stats.isPersonaConfigured ? '✓' : '—',
          icon: Icons.person,
          backgroundColor: stats.isPersonaConfigured
              ? Theme.of(
                  context,
                ).colorScheme.onInverseSurface.withValues(alpha: 0.5)
              : null,
          onTap: () => ProfileRoute().push(context),
        ),
        StatCard(
          title: 'Instructions',
          value: stats.isCustomInstructionsSet ? '✓' : '—',
          icon: Icons.note_alt,
          backgroundColor: stats.isCustomInstructionsSet
              ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1)
              : null,
          onTap: () => SettingsRoute().push(context),
        ),
      ],
    );
  }

  /// Build feature cards for setup
  Widget _buildFeatureCards(BuildContext context, DashboardStats stats) {
    return Column(
      children: [
        FeatureCard(
          title: 'Set Up Your Persona',
          description: 'Create your digital persona for AI interactions',
          icon: Icons.person_add,
          isConfigured: stats.isPersonaConfigured,
          onTap: () => ProfileRoute().push(context),
        ),
        const SizedBox(height: 12),
        FeatureCard(
          title: 'Custom Instructions',
          description: 'Add custom instructions for the AI',
          icon: Icons.note_add,
          isConfigured: stats.isCustomInstructionsSet,
          onTap: () => SettingsRoute().push(context),
        ),
      ],
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          label: 'Chat About Today',
          icon: Icons.chat_outlined,
          onPressed: () => DailyChatRoute().push(context),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                label: 'View Saved',
                icon: Icons.bookmark,
                onPressed: () => SavedRoute().push(context),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QuickActionButton(
                label: 'Profile',
                icon: Icons.account_circle,
                onPressed: () => ProfileRoute().push(context),
                backgroundColor: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
