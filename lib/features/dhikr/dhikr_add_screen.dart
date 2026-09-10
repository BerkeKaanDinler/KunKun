import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../ui/atoms.dart';
import '../../ui/buttons.dart';
import '../../ui/glass.dart';
import '../../ui/metrics.dart';
import '../../ui/text_field.dart';

/// Z7 · Serbest zikir ekle — `Zikir Ekranlari.dc.html`
///
/// Üstte İptal / Kaydet · 27 px başlık · ZİKRİN ADI · ARAPÇA METİN
/// (isteğe bağlı, `dir="rtl"`) · TÜRKÇE ANLAM · SAYAÇ bölümü.
///
/// **Hedef seçimi yoktur** — serbest tarafta hedef yok, sayaç durmaz.
class DhikrAddScreen extends ConsumerStatefulWidget {
  const DhikrAddScreen({super.key});

  @override
  ConsumerState<DhikrAddScreen> createState() => _DhikrAddScreenState();
}

class _DhikrAddScreenState extends ConsumerState<DhikrAddScreen> {
  final _name = TextEditingController();
  final _arabic = TextEditingController();
  final _meaning = TextEditingController();
  bool _vibrate = true;

  @override
  void initState() {
    super.initState();
    _name.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _name
      ..removeListener(_onChange)
      ..dispose();
    _arabic.dispose();
    _meaning.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_canSave) return;
    final ar = _arabic.text.trim();
    final me = _meaning.text.trim();
    await ref
        .read(dhikrRepositoryProvider)
        .addCustom(
          CustomDhikr(
            id: 'c${DateTime.now().microsecondsSinceEpoch}',
            name: _name.text.trim(),
            // Boş bırakılırsa null — uydurma metin yazılmaz.
            textAr: ar.isEmpty ? null : ar,
            meaning: me.isEmpty ? null : me,
            sortOrder: 0,
            vibrateEvery33: _vibrate,
            createdAt: DateTime.now(),
          ),
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final media = MediaQuery.of(context);

    return ColoredBox(
      color: t.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: media.padding.top > KunMetrics.screenTop
              ? media.padding.top
              : KunMetrics.screenTop,
          bottom: KunMetrics.screenBottomOnboarding + media.padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TopAction(label: 'İptal', onTap: () => context.pop()),
                  _TopAction(
                    label: 'Kaydet',
                    bold: true,
                    onTap: _canSave ? _save : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  KunMetrics.gutterCard,
                  8,
                  KunMetrics.gutterCard,
                  KunMetrics.v16,
                ),
                children: [
                  Text(
                    'Serbest zikir',
                    style: context.type
                        .sectionTitle(t.textPrimary)
                        .copyWith(letterSpacing: 27 * -0.02),
                  ),
                  const SizedBox(height: KunMetrics.v9),
                  Text(
                    'Serbest zikirler sınırsız sayar; hedef yok, sayacı '
                    'istediğinde sıfırlarsın. Yalnızca cihazında saklanır.',
                    style: context.type.body(t.textSecondary),
                  ),
                  const SizedBox(height: KunMetrics.v20),
                  SectionHeader('Zikrin adı'),
                  KunTextField(
                    controller: _name,
                    hint: 'Örneğin: sabah zikri',
                    autofocus: true,
                  ),
                  const SizedBox(height: KunMetrics.v16),
                  SectionHeader('Arapça metin · isteğe bağlı'),
                  KunTextField(
                    controller: _arabic,
                    hint: 'Arapça metin',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: KunMetrics.v16),
                  SectionHeader('Türkçe anlam'),
                  KunTextField(controller: _meaning, hint: 'Anlamı'),
                  const SizedBox(height: KunMetrics.v20),
                  SectionHeader('Sayaç'),
                  GlassSurface(
                    radius: t.radiusSm,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        const KunBadge('∞', accented: true),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'Sınırsız sayar. Hedef yok; sayacı istediğin an '
                            'sıfırlarsın.',
                            style: context.type
                                .caption(t.textSecondary, size: 13)
                                .copyWith(height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: KunMetrics.v12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Her dokunuşta titreşim',
                          style: context.type.body(t.textPrimary, size: 15),
                        ),
                      ),
                      KunSwitch(
                        value: _vibrate,
                        onChanged: (v) => setState(() => _vibrate = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KunMetrics.gutterCard,
              ),
              child: PrimaryButton(
                label: 'Serbest listeme ekle',
                onPressed: _canSave ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.label, this.onTap, this.bold = false});

  final String label;
  final VoidCallback? onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.type
                .body(t.accent, size: 17)
                .copyWith(fontWeight: bold ? FontWeight.w600 : FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
