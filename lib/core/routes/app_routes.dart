import 'package:flutter/material.dart'; // Must include for Widget/Scaffold
import 'package:go_router/go_router.dart';
import 'package:mindlog/features/daily/presentation/screens/daily_chat_screen.dart';
import 'package:mindlog/features/editor/presentation/screens/entry_editor_screen.dart';
import 'package:mindlog/features/landing_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LandingScreen();
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
  const EntryEditorRoute({this.entryId, this.dayKey});
  final int? entryId;
  final int? dayKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EntryEditorScreen(entryId: entryId, dayKey: dayKey);
  }
}
