import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../ui/icons.dart';
import '../../ui/logo_mark.dart';
import '../../ui/surfaces.dart';
import 'onboarding_controller.dart';
import 'onboarding_shell.dart';

/// 2–3 · Tanıtım 1 ve 2 — `Temiz Secilen Temalar.dc.html` · `0b`, `0c`
///
/// Tanıtım 1: 154 px görsel blok (aksan %18 zemin, ortada 118 px logo).
/// Tanıtım 2: ayet kartı önizlemesi (opak kart · künye · metin · üç ikon).
/// İkisinde de 30/700 `-.02em` başlık ve 17/1.55 `--text-secondary` gövde.
class IntroScreen extends ConsumerWidget {
  const IntroScreen({required this.step, super.key});

  /// 0 → Tanıtım 1 · 1 → Tanıtım 2
  final int step;

  static const List<({String title, String body})> _pages = [
    (
      title: 'Hissettiğin duyguya göre ayetler',
      body:
          'Kaygı, şükür, borç, yolculuk… 160 konu başlığı. '
          'Sure numarası bilmene gerek yok.',
    ),
    (
      title: 'Dinle, kaydet, mealleri karşılaştır',
      body:
          'Kayıtların cihazında kalır. Hesap açman gerekmez, '
          'çevrimdışı çalışır.',
    ),
  ];

  void _skip(WidgetRef ref, BuildContext context) {
    ref.read(onboardingProvider.notifier).skip();
    context.go('/ana');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final page = _pages[step];

    return OnboardingShell(
      stepIndex: step,
      buttonLabel: 'Devam',
      onButton: () => context.go(step == 0 ? '/tanitim/2' : '/isim'),
      onSkip: () => _skip(ref, context),
      contentGap: step == 0 ? 26 : 24,
      content: [
        step == 0 ? const _LogoBlock() : const _VersePreviewCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              page.title,
              style: context.type
                  .cardTitle(t.textPrimary, size: 30)
                  .copyWith(height: 1.2, letterSpacing: 30 * -0.02),
            ),
            const SizedBox(height: 12),
            Text(
              page.body,
              style: context.type
                  .body(t.textSecondary, size: 17)
                  .copyWith(height: 1.55),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tanıtım 1 · 154 px blok, aksanın %18'i zemin, ortada 118 px logo.
class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      height: 154,
      decoration: BoxDecoration(
        color: t.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(t.radiusLg),
      ),
      alignment: Alignment.center,
      child: const LogoMark(size: 118),
    );
  }
}

/// Tanıtım 2 · ayet kartı önizlemesi.
///
/// **İçerik notu:** tasarım mock'unda burada gerçek bir meal ve gerçek bir
/// `sure:ayet` referansı var. Ü6/Ü7 fixture politikası gereği uygulamada
/// yer tutucu gösterilir — lisans kuralı da çevirmen künyesi olmadan meal
/// gösterilmesini engeller. Gerçek veri Aşama 2'de gelir.
class _VersePreviewCard extends StatelessWidget {
  const _VersePreviewCard();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return OpaqueCard(
      radius: t.radiusLg,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÖRNEK 01:03',
            style: context.type
                .meta(t.textSecondary, size: 11, weight: FontWeight.w600)
                .copyWith(letterSpacing: 11 * 0.1),
          ),
          const SizedBox(height: 11),
          Text(
            'Bu bir yer tutucu metindir. Gerçek meal verisi henüz eklenmedi.',
            style: context.type
                .body(t.textPrimary, size: 19)
                .copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(KunIcons.play, size: 19, color: t.accent),
              const SizedBox(width: 16),
              Icon(KunIcons.bookmarkBorder, size: 19, color: t.textPrimary),
              const SizedBox(width: 16),
              Icon(KunIcons.share, size: 19, color: t.textPrimary),
            ],
          ),
        ],
      ),
    );
  }
}
