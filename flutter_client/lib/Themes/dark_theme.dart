import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

ThemeData darkTheme = FlexThemeData.dark(
  appBarOpacity: 0,
  colors: const FlexSchemeColor(
    primary: Color(0xff629f80),
    primaryContainer: Color(0xff274033),
    secondary: Color(0xff81b39a),
    secondaryContainer: Color(0xff4d6b5c),
    tertiary: Color(0xff88c5a6),
    tertiaryContainer: Color(0xff356c50),
    appBarColor: Color(0xff356c50),
    error: Color(0xffcf6679),
  ),
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
    switchSchemeColor: SchemeColor.secondary,
    switchThumbFixedSize: true,
    navigationBarOpacity: 0,
    bottomNavigationBarOpacity: 0,
    bottomNavigationBarElevation: 0,
  ),
  useMaterial3ErrorColors: true,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
);
