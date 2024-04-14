import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = FlexThemeData.light(
  scheme: FlexScheme.greenM3,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: false,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  ),
  useMaterial3ErrorColors: true,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);
