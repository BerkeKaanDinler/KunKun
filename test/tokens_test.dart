import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kun/core/theme/kun_theme.dart';
import 'package:kun/core/theme/themes/themes.dart';
import 'package:kun/core/theme/tokens.dart';

void main() {
  group('Tema katmanı', () {
    test('altı tema tanımlı ve varsayılan Cam · gece', () {
      expect(kunThemes.length, 6);
      expect(kunDefaultTheme.id, KunThemeId.gece);
    });

    test('glass-blur: cam temalarda 20, Kâğıt indeks 0', () {
      for (final e in kunThemes.entries) {
        final expected = e.key == KunThemeId.kagit ? 0.0 : 20.0;
        expect(e.value.tokens.glassBlur, expected, reason: e.key.slug);
      }
    });

    test('Kâğıt indeks cam değil — opak kod yoluna düşer', () {
      expect(kunThemeKagit.tokens.isGlass, isFalse);
      expect(kunThemeKagit.shadows.primaryButton, isEmpty);
      expect(kunThemeKagit.tokens.radiusLg, 4);
      expect(kunThemeKagit.tokens.radiusMd, 4);
      expect(kunThemeKagit.tokens.radiusSm, 4);
    });

    test('GlassLayer mutlak px döner, glassBlur 0 iken hepsi 0', () {
      final cam = kunThemeGece.tokens;
      expect(GlassLayer.base.resolve(cam), 20);
      expect(GlassLayer.nested.resolve(cam), 18);
      expect(GlassLayer.dense.resolve(cam), 22);
      expect(GlassLayer.bar.resolve(cam), 24);

      final opak = kunThemeKagit.tokens;
      for (final l in GlassLayer.values) {
        expect(l.resolve(opak), 0, reason: l.name);
      }
    });

    test('slug kalıcı tercihte saklanır — geri okunabilmeli', () {
      for (final id in KunThemeId.values) {
        expect(KunThemeId.fromSlug(id.slug), id);
      }
      expect(KunThemeId.fromSlug('yok'), isNull);
      expect(KunThemeId.fromSlug(null), isNull);
    });

    test('aksan üstü metin her temada tanımlı ve aksandan farklı', () {
      for (final t in kunThemes.values) {
        expect(t.tokens.onAccent, isNot(t.tokens.accent), reason: t.id.slug);
      }
    });

    test('Arapça minimum 14 px — harekeler daha küçükte okunmaz', () {
      const ty = KunTypography();
      expect(ty.arabicText(const Color(0xFF000000), size: 9).fontSize, 14);
      expect(ty.arabicText(const Color(0xFF000000), size: 30).height, 1.5);
      expect(ty.arabicText(const Color(0xFF000000), size: 15).height, 1.45);
    });
  });
}
