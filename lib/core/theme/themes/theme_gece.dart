// md/04-tema-cam-gece.md — VARSAYILAN TEMA. Değerler birebir alınmıştır.
import 'package:flutter/widgets.dart';

import '../kun_theme.dart';
import '../tokens.dart';

const kunThemeGece = KunTheme(
  id: KunThemeId.gece,
  brightness: Brightness.dark,
  logoAsset: 'assets/logo/0A84FF-isik.png',
  typography: KunTypography(),
  shadows: KunShadows(
    primaryButton: [
      BoxShadow(
        color: Color(0x59000000),
        blurRadius: 26,
        offset: Offset(0, 10),
      ),
    ],
  ),
  tokens: KunTokens(
    surface: Color(0xFF0F1115),
    surfaceRaised: Color(0xFF191C22),
    surfaceSunken: Color(0xFF14171C),
    border: Color.fromRGBO(255, 255, 255, .12),
    divider: Color.fromRGBO(255, 255, 255, .10),
    accent: Color(0xFF0A84FF),
    accentSoft: Color.fromRGBO(10, 132, 255, .16),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color.fromRGBO(235, 235, 245, .62),
    textTertiary: Color.fromRGBO(235, 235, 245, .40),
    track: Color.fromRGBO(235, 235, 245, .14),
    heroSurface: Color(0xFF1B2430),
    danger: Color(0xFFFF6B5E),
    glassFill: Color.fromRGBO(255, 255, 255, .08),
    glassBorder: Color.fromRGBO(255, 255, 255, .14),
    glassBlur: 20,
    radiusLg: 22,
    radiusMd: 18,
    radiusSm: 14,
  ),
);
