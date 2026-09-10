// md/06-tema-cam-yesim-acik.md — değerler birebir alınmıştır.
import 'package:flutter/widgets.dart';

import '../kun_theme.dart';
import '../tokens.dart';

const kunThemeYesimAcik = KunTheme(
  id: KunThemeId.yesimAcik,
  brightness: Brightness.light,
  logoAsset: 'assets/logo/1F7A5C-koyu.png',
  typography: KunTypography(),
  shadows: KunShadows(
    primaryButton: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 26,
        offset: Offset(0, 10),
      ),
    ],
    glass: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 26,
        offset: Offset(0, 10),
      ),
    ],
  ),
  tokens: KunTokens(
    surface: Color(0xFFEEF4F1),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE4EDE8),
    border: Color.fromRGBO(30, 70, 58, .13),
    divider: Color.fromRGBO(30, 70, 58, .14),
    accent: Color(0xFF1F7A5C),
    accentSoft: Color.fromRGBO(31, 122, 92, .12),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF12241E),
    textSecondary: Color.fromRGBO(20, 50, 42, .64),
    textTertiary: Color.fromRGBO(20, 50, 42, .44),
    track: Color.fromRGBO(20, 50, 42, .14),
    heroSurface: Color(0xFF2A5F4C),
    danger: Color(0xFFB3261E),
    glassFill: Color.fromRGBO(255, 255, 255, .70),
    glassBorder: Color.fromRGBO(255, 255, 255, .92),
    glassBlur: 20,
    radiusLg: 22,
    radiusMd: 18,
    radiusSm: 14,
  ),
);
