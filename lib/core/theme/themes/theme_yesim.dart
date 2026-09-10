// md/01-tema-cam-gece-yesimi.md — değerler birebir alınmıştır.
import 'package:flutter/widgets.dart';

import '../kun_theme.dart';
import '../tokens.dart';

const kunThemeYesim = KunTheme(
  id: KunThemeId.yesim,
  brightness: Brightness.dark,
  logoAsset: 'assets/logo/4FD1A5-isik.png',
  typography: KunTypography(),
  shadows: KunShadows(
    primaryButton: [
      BoxShadow(
        color: Color(0x80000000),
        blurRadius: 30,
        offset: Offset(0, 14),
      ),
    ],
  ),
  tokens: KunTokens(
    surface: Color(0xFF0B1613),
    surfaceRaised: Color(0xFF122019),
    surfaceSunken: Color(0xFF0F1B16),
    border: Color.fromRGBO(255, 255, 255, .12),
    divider: Color.fromRGBO(255, 255, 255, .09),
    accent: Color(0xFF4FD1A5),
    accentSoft: Color.fromRGBO(79, 209, 165, .14),
    onAccent: Color(0xFF10100F),
    textPrimary: Color(0xFFE8F2EC),
    textSecondary: Color.fromRGBO(232, 242, 236, .62),
    textTertiary: Color.fromRGBO(232, 242, 236, .40),
    track: Color.fromRGBO(232, 242, 236, .14),
    heroSurface: Color(0xFF12332A),
    danger: Color(0xFFFF6B5E),
    glassFill: Color.fromRGBO(140, 220, 190, .09),
    glassBorder: Color.fromRGBO(160, 230, 200, .16),
    glassBlur: 20,
    radiusLg: 22,
    radiusMd: 18,
    radiusSm: 14,
  ),
);
