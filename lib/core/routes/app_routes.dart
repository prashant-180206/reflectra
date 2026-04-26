import 'package:flutter/material.dart'; // Must include for Widget/Scaffold
import 'package:go_router/go_router.dart';
import 'package:mindlog/features/daily/presentation/screens/daily_chat_screen.dart';
import 'package:mindlog/features/entry/presentation/screens/entry_editor_screen.dart';
import 'package:mindlog/features/entry/presentation/screens/entry_viewer_screen.dart';
import 'package:mindlog/features/home_screen.dart';
import 'package:mindlog/features/profile/presentation/screens/persona_maker_chat_screen.dart';
import 'package:mindlog/features/profile/presentation/screens/profile_screen.dart';
import 'package:mindlog/features/saved/saved_screen.dart';
import 'package:mindlog/features/settings/settings_screen.dart';

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

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
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
