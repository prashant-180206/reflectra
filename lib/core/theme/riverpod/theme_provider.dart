import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'theme_provider.g.dart';

@riverpod
class AppTheme extends _$AppTheme {
  static const _key = 'app_theme';

  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    if (saved != null) {
      return ThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeMode.light,
      );
    }

    return ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.value ?? ThemeMode.light;
    final newTheme =
        current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newTheme.name);

    state = AsyncData(newTheme);
  }
}

@riverpod
class AppColorScheme extends _$AppColorScheme {
  static const _key = 'app_color_scheme';

  @override
  Future<FlexScheme> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    if (saved != null) {
      return FlexScheme.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => FlexScheme.materialBaseline,
      );
    }

    return FlexScheme.materialBaseline;
  }

  Future<void> setScheme(FlexScheme scheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, scheme.name);

    state = AsyncData(scheme);
  }
}