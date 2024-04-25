import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = FlexThemeData.light(
  scheme: FlexScheme.green,
  appBarOpacity: 0,
  appBarElevation: 0,
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
    navigationBarOpacity: 0,
    bottomNavigationBarOpacity: 0,
    bottomNavigationBarElevation: 0,
    bottomNavigationBarType: BottomNavigationBarType.fixed,
    chipRadius: 20,
    chipSchemeColor: SchemeColor.secondary,
  ),
  useMaterial3ErrorColors: true,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);
