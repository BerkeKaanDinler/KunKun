import '../kun_theme.dart';
import 'theme_bakir.dart';
import 'theme_gece.dart';
import 'theme_kagit.dart';
import 'theme_murekkep.dart';
import 'theme_yesim.dart';
import 'theme_yesim_acik.dart';

export 'theme_bakir.dart';
export 'theme_gece.dart';
export 'theme_kagit.dart';
export 'theme_murekkep.dart';
export 'theme_yesim.dart';
export 'theme_yesim_acik.dart';

/// Varsayılan tema — `md/04-tema-cam-gece.md`, "ilk açılışta yüklenen tema".
const KunTheme kunDefaultTheme = kunThemeGece;

const Map<KunThemeId, KunTheme> kunThemes = {
  KunThemeId.yesim: kunThemeYesim,
  KunThemeId.murekkep: kunThemeMurekkep,
  KunThemeId.bakir: kunThemeBakir,
  KunThemeId.gece: kunThemeGece,
  KunThemeId.kagit: kunThemeKagit,
  KunThemeId.yesimAcik: kunThemeYesimAcik,
};

KunTheme kunThemeOf(KunThemeId id) => kunThemes[id] ?? kunDefaultTheme;
