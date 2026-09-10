// md/03-tema-cam-komur-bakir.md — değerler birebir alınmıştır.
import 'package:flutter/widgets.dart';

import '../kun_theme.dart';
import '../tokens.dart';

const kunThemeBakir = KunTheme(
  id: KunThemeId.bakir,
  brightness: Brightness.dark,
  logoAsset: 'assets/logo/E0894A-isik.png',
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
    surface: Color(0xFF121110),
    surfaceRaised: Color(0xFF1C1A18),
    surfaceSunken: Color(0xFF171514),
    border: Color.fromRGBO(255, 255, 255, .12),
    divider: Color.fromRGBO(255, 255, 255, .09),
    accent: Color(0xFFE0894A),
    accentSoft: Color.fromRGBO(224, 137, 74, .14),
    onAccent: Color(0xFF10100F),
    textPrimary: Color(0xFFF2EDE7),
    textSecondary: Color.fromRGBO(242, 237, 231, .60),
    textTertiary: Color.fromRGBO(242, 237, 231, .38),
    track: Color.fromRGBO(242, 237, 231, .14),
    heroSurface: Color(0xFF2B211A),
    danger: Color(0xFFFF6B5E),
    glassFill: Color.fromRGBO(255, 235, 215, .07),
    glassBorder: Color.fromRGBO(255, 225, 200, .14),
    glassBlur: 20,
    radiusLg: 22,
    radiusMd: 18,
    radiusSm: 14,
  ),
);
