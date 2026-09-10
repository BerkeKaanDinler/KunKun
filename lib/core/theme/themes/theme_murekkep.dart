// md/02-tema-cam-murekkep-moru.md — değerler birebir alınmıştır.
import 'package:flutter/widgets.dart';

import '../kun_theme.dart';
import '../tokens.dart';

const kunThemeMurekkep = KunTheme(
  id: KunThemeId.murekkep,
  brightness: Brightness.dark,
  logoAsset: 'assets/logo/A78BFA-isik.png',
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
    surface: Color(0xFF0F0C18),
    surfaceRaised: Color(0xFF181428),
    surfaceSunken: Color(0xFF141020),
    border: Color.fromRGBO(255, 255, 255, .13),
    divider: Color.fromRGBO(255, 255, 255, .10),
    accent: Color(0xFFA78BFA),
    accentSoft: Color.fromRGBO(167, 139, 250, .14),
    onAccent: Color(0xFF10100F),
    textPrimary: Color(0xFFEDE9FB),
    textSecondary: Color.fromRGBO(237, 233, 251, .62),
    textTertiary: Color.fromRGBO(237, 233, 251, .40),
    track: Color.fromRGBO(237, 233, 251, .14),
    heroSurface: Color(0xFF241B3D),
    danger: Color(0xFFFF6B5E),
    glassFill: Color.fromRGBO(180, 160, 255, .10),
    glassBorder: Color.fromRGBO(190, 175, 255, .18),
    glassBlur: 20,
    radiusLg: 22,
    radiusMd: 18,
    radiusSm: 14,
  ),
);
