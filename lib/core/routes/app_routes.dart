import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart'; // Must include for Widget/Scaffold
import 'package:go_router/go_router.dart';
import 'package:reflectra/features/daily/presentation/screens/daily_chat_screen.dart';
import 'package:reflectra/features/entry/presentation/screens/entry_editor_screen.dart';
import 'package:reflectra/features/entry/presentation/screens/entry_viewer_screen.dart';
import 'package:reflectra/features/home/presentation/screen/home_screen.dart';
import 'package:reflectra/features/profile/presentation/screens/instruction_configuration_screen.dart';
import 'package:reflectra/features/profile/presentation/screens/persona_viewer_editor_screen.dart';
import 'package:reflectra/features/profile/presentation/screens/persona_maker_chat_screen.dart';
import 'package:reflectra/features/profile/presentation/screens/profile_screen.dart';
import 'package:reflectra/features/saved/saved_screen.dart';
import 'package:reflectra/features/settings/presentation/screens/advanced_settings_screen.dart';
import 'package:reflectra/features/settings/presentation/screens/settings_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<RootRoute>(path: '/')
class RootRoute extends GoRouteData with $RootRoute {
  const RootRoute();

  @override
  String redirect(BuildContext context, GoRouterState state) {
    return const HomeRoute().location;
  }
}

@TypedShellRoute<AppShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<HomeRoute>(path: '/home'),
    TypedGoRoute<SavedRoute>(path: '/saved'),
    TypedGoRoute<ProfileRoute>(path: '/profile'),
    TypedGoRoute<PersonaViewerEditorRoute>(path: '/profile/persona'),
    TypedGoRoute<InstructionConfigurationRoute>(path: '/profile/instructions'),
    TypedGoRoute<SettingsRoute>(path: '/settings'),
  ],
)
class AppShellRoute extends ShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppShell(location: state.uri.path, child: navigator);
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  int _selectedIndex() {
    if (location.startsWith(SavedRoute.path)) {
      return 1;
    }
    if (location.startsWith(ProfileRoute.path)) {
      return 2;
    }
    if (location.startsWith(SettingsRoute.path)) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: child,
      bottomNavigationBar: ConvexAppBar(
        height: 60,
        top: -5,
        backgroundColor: colorScheme.surfaceContainer,
        activeColor: theme.brightness == Brightness.dark
            ? colorScheme.inversePrimary
            : colorScheme.primaryFixedDim,
        color: colorScheme.onSurfaceVariant,
        initialActiveIndex: selectedIndex,
        onTap: (index) {
          if (index == selectedIndex) {
            return;
          }

          switch (index) {
            case 0:
              const HomeRoute().go(context);
            case 1:
              const SavedRoute().go(context);
            case 2:
              const ProfileRoute().go(context);
            case 3:
              const SettingsRoute().go(context);
          }
        },
        items: const [
          TabItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            title: 'Home',
          ),
          TabItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            title: 'Saved',
          ),
          TabItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            title: 'Profile',
          ),
          TabItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            title: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  static const String path = '/home';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

class SavedRoute extends GoRouteData with $SavedRoute {
  const SavedRoute();

  static const String path = '/saved';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SavedScreen();
  }
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  static const String path = '/profile';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}

class PersonaViewerEditorRoute extends GoRouteData
    with $PersonaViewerEditorRoute {
  const PersonaViewerEditorRoute();

  static const String path = '/profile/persona';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PersonaViewerEditorScreen();
  }
}

class InstructionConfigurationRoute extends GoRouteData
    with $InstructionConfigurationRoute {
  const InstructionConfigurationRoute();

  static const String path = '/profile/instructions';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const InstructionConfigurationScreen();
  }
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  static const String path = '/settings';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

@TypedGoRoute<DailyChatRoute>(path: '/dailychat')
class DailyChatRoute extends GoRouteData with $DailyChatRoute {
  const DailyChatRoute({this.dayKey});
  final int? dayKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DailyChatScreen(dayKey: dayKey);
  }
}

@TypedGoRoute<EntryEditorRoute>(path: '/editor')
class EntryEditorRoute extends GoRouteData with $EntryEditorRoute {
  const EntryEditorRoute({this.entryId});
  final int? entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EntryEditorScreen(entryId: entryId ?? 0);
  }
}

@TypedGoRoute<EntryViewerRoute>(path: '/viewentry')
class EntryViewerRoute extends GoRouteData with $EntryViewerRoute {
  const EntryViewerRoute({this.entryId});
  final int? entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EntryViewerScreen(entryId: entryId ?? 0);
  }
}

@TypedGoRoute<PersonaMakingChatRoute>(path: '/personachat')
class PersonaMakingChatRoute extends GoRouteData with $PersonaMakingChatRoute {
  const PersonaMakingChatRoute();
  // final int? entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PersonaMakingChatScreen();
  }
}

@TypedGoRoute<AiSettingsRoute>(path: '/aisettings')
class AiSettingsRoute extends GoRouteData with $AiSettingsRoute {
  const AiSettingsRoute();
  // final int? entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdvancedSettingsScreen();
  }
}
