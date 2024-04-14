import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

ThemeData darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.greenM3,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: false,
    inputDecoratorBackgroundAlpha: 0,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  ),
  useMaterial3ErrorColors: true,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);
