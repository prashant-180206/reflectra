import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class MainAppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light(FlexScheme scheme) => FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: scheme,
    // Surface color adjustments.
    surfaceMode: FlexSurfaceMode.level,
    blendLevel: 40,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      splashType: FlexSplashType.inkSplash,
      inputDecoratorSchemeColor: SchemeColor.primaryFixed,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 24.0,
      listTileIconSchemeColor: SchemeColor.primary,
      listTileTextSchemeColor: SchemeColor.onPrimaryContainer,
      listTileSelectedTileSchemeColor: SchemeColor.primaryContainer,
      cardBackgroundSchemeColor: SchemeColor.primaryFixed,
      cardBorderSchemeColor: SchemeColor.primaryFixedDim,
      cardElevation: 6.0,
      alignedDropdown: true,
      dialogBackgroundSchemeColor: SchemeColor.secondaryContainer,
      datePickerHeaderBackgroundSchemeColor: SchemeColor.secondary,
      snackBarRadius: 35,
      snackBarElevation: 7,
      appBarBackgroundSchemeColor: SchemeColor.primary,
      appBarScrolledUnderElevation: 15.5,
      tabBarItemSchemeColor: SchemeColor.onPrimary,
      tabBarUnselectedItemSchemeColor: SchemeColor.onInverseSurface,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark(FlexScheme scheme) => FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: scheme,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      splashType: FlexSplashType.inkSplash,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 24.0,
      listTileIconSchemeColor: SchemeColor.primary,
      listTileTextSchemeColor: SchemeColor.onPrimaryContainer,
      listTileTileSchemeColor: SchemeColor.onPrimaryFixed,
      listTileSelectedTileSchemeColor: SchemeColor.onPrimaryFixedVariant,
      cardBackgroundSchemeColor: SchemeColor.onPrimaryFixedVariant,
      cardBorderSchemeColor: SchemeColor.onSecondaryFixed,
      cardElevation: 6.0,
      alignedDropdown: true,
      datePickerHeaderBackgroundSchemeColor: SchemeColor.secondary,
      snackBarRadius: 35,
      snackBarElevation: 7,
      appBarBackgroundSchemeColor: SchemeColor.onPrimaryFixed,
      appBarForegroundSchemeColor: SchemeColor.onPrimaryContainer,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
