import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class AppTheme extends _$AppTheme {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void toggle(){
    if (state == ThemeMode.light){
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }
}
