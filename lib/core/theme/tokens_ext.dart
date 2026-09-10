import 'package:flutter/widgets.dart';

import 'kun_theme.dart';
import 'theme_controller.dart';
import 'tokens.dart';

/// Bileşenlerin tek erişim yolu.
///
///     color: context.tokens.textPrimary      // DOĞRU
///     color: const Color(0xFFF2F3F5)         // YANLIŞ
extension KunThemeContext on BuildContext {
  KunTheme get kunTheme => KunThemeScope.of(this);
  KunTokens get tokens => KunThemeScope.of(this).tokens;
  KunTypography get type => KunThemeScope.of(this).typography;
  KunShadows get shadows => KunThemeScope.of(this).shadows;
}
