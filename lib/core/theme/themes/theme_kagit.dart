// md/05-tema-kagit-indeks.md — cam yok, blur yok, gölge yok.
// glassBlur: 0 → bütün cam kod yolu bu temada opak yüzeye düşer.
import 'package:flutter/widgets.dart';

import '../kun_theme.dart';
import '../tokens.dart';

const kunThemeKagit = KunTheme(
  id: KunThemeId.kagit,
  brightness: Brightness.light,
  logoAsset: 'assets/logo/2B4A5A-koyu.png',
  typography: KunTypography(
    bodyFamily: 'LibreFranklin',
    headingFamily: 'Spectral',
    headingWeight: FontWeight.w600,
    titleLetterSpacing: -0.01,
  ),
  shadows: KunShadows(),
  tokens: KunTokens(
    surface: Color(0xFFEAE8E1),
    surfaceRaised: Color(0xFFF4F3EE),
    surfaceSunken: Color(0xFFDCD9CE),
    border: Color(0xFFE0DCD2),
    divider: Color(0xFFE0DCD2),
    accent: Color(0xFF2B4A5A),
    accentSoft: Color.fromRGBO(43, 74, 90, .12),
    onAccent: Color(0xFFF6F5F0),
    textPrimary: Color(0xFF1A1A17),
    textSecondary: Color.fromRGBO(26, 26, 23, .66),
    textTertiary: Color.fromRGBO(26, 26, 23, .46),
    track: Color.fromRGBO(26, 26, 23, .14),
    heroSurface: Color(0xFF2B4A5A),
    danger: Color(0xFFB3261E),
    glassFill: Color(0xFFF4F3EE),
    glassBorder: Color(0xFFE0DCD2),
    glassBlur: 0,
    radiusLg: 4,
    radiusMd: 4,
    radiusSm: 4,
  ),
);
