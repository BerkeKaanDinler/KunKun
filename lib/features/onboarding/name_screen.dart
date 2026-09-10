import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../ui/text_field.dart';
import 'onboarding_controller.dart';
import 'onboarding_shell.dart';

/// 4 · İsim (atlanabilir) — `Temiz Secilen Temalar.dc.html` · `0d`
///
/// 30/700 `-.02em` başlık, 17/1.55 gövde, tek metin alanı
/// (dolgu 16, `--surface-raised`, kenar `--accent`, köşe `--radius-sm`).
/// Sağ üstte "Atla", altta 3 nokta ve "Başla".
///
/// **Gizlilik:** mimari brief "yalnızca telefonunda saklanır" cümlesini
/// zorunlu kılıyor; tasarım mock'u aynı güvenceyi "Cihazından çıkmaz"
/// diye veriyor. Brief kazanır → cümle birebir kullanılıyor, tasarımın
/// cümle uzunluğu ve ritmi korunuyor.
class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(onboardingProvider).name ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    ref.read(onboardingProvider.notifier).finish(name: _controller.text);
    context.go('/ana');
  }

  void _skip() {
    ref.read(onboardingProvider.notifier).skip();
    context.go('/ana');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return OnboardingShell(
      stepIndex: 2,
      buttonLabel: 'Başla',
      onButton: _start,
      onSkip: _skip,
      contentGap: 24,
      content: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sana nasıl hitap edelim?',
              style: context.type
                  .cardTitle(t.textPrimary, size: 30)
                  .copyWith(height: 1.2, letterSpacing: 30 * -0.02),
            ),
            const SizedBox(height: 12),
            Text(
              'Ana sayfada selamlamak için. İsmin '
              'yalnızca telefonunda saklanır, boş bırakabilirsin.',
              style: context.type
                  .body(t.textSecondary, size: 17)
                  .copyWith(height: 1.55),
            ),
          ],
        ),
        KunTextField(
          controller: _controller,
          hint: 'İsmin',
          onSubmitted: (_) => _start(),
        ),
      ],
    );
  }
}
