import 'package:flutter/material.dart';
import 'package:mindlog/core/database/database.dart';
import 'package:mindlog/core/routes/app_router.dart';
import 'package:mindlog/core/theme/riverpod/theme_provider.dart';
import 'package:mindlog/core/theme/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.init();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    return MaterialApp.router(
      routerConfig: goRouter,
      theme: MainAppTheme.light,
      darkTheme: MainAppTheme.dark,
      themeMode: themeMode,
    );
  }
}
