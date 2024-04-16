import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = FlexThemeData.light(
  appBarOpacity: 0,
  appBarElevation: 0,
  colors: const FlexSchemeColor(
    primary: Color(0xFF08740A),
    primaryContainer: Color(0xff9ee29f),
    secondary: Color(0xff365b37),
    secondaryContainer: Color(0xFF8FBF92),
    tertiary: Color(0xff2c7e2e),
    tertiaryContainer: Color(0xffb8e6b9),
    appBarColor: Color(0xffb8e6b9),
    error: Color(0xffb00020),
  ),
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
    switchSchemeColor: SchemeColor.secondary,
    switchThumbFixedSize: true,
    bottomNavigationBarOpacity: 0,
    bottomNavigationBarElevation: 0,
  ),
  useMaterial3ErrorColors: true,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);
