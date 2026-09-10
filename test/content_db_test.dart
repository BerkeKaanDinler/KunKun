import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Mimari brief · "Zorunlu build kontrolleri. Bunlar CI testidir;
/// tutmazsa build başarısız olur."
///
/// Bu test `tool/build_content_db.py` betiğini çalıştırır ve dört kontrolün
/// hepsinin geçtiğini doğrular. Betik CI'da ayrıca doğrudan çalıştırılabilir.
void main() {
  late Map<String, dynamic> report;
  late int exitCode;

  setUpAll(() {
    final out = '${Directory.systemTemp.path}/kun_content.db';
    final rep = '${Directory.systemTemp.path}/kun_content_report.json';
    final r = Process.runSync(
      'python3',
      [
        'tool/build_content_db.py',
        '--source',
        'assets/fixtures',
        '--out',
        out,
        '--report',
        rep,
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    exitCode = r.exitCode;
    report = jsonDecode(File(rep).readAsStringSync()) as Map<String, dynamic>;
  });

  group('Zorunlu build kontrolleri', () {
    test('betik sıfır kodla biter', () {
      expect(exitCode, 0);
    });

    test('1 · ayet sayısı doğrulaması temiz', () {
      // Besmele sayımı farkı buradan yakalanır: sûrenin bildirdiği ayet
      // sayısı, yazılan ayet sayısı ve HER mealdeki satır sayısı eşit olmalı.
      expect(report['verseCountProblems'], isEmpty);
    });

    test('2 · kapsama raporu üretiliyor', () {
      final cov = report['coverage'] as Map<String, dynamic>;
      expect(cov['totalCategories'], 160);
      // Ü10 · fixture'da 22 kategori kasıtlı boş; gerçek veride --strict
      // bunu hataya çevirir.
      expect(cov['emptyCount'], inInclusiveRange(15, 30));
    });

    test('3 · lisans kaydı tam', () {
      expect(report['licenseProblems'], isEmpty);
    });

    test('4 · checksum üretiliyor ve dosyayla eşleşiyor', () {
      final digest = report['sha256'] as String;
      expect(digest, hasLength(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(digest), isTrue);

      // Aynı kaynaktan ikinci üretim aynı checksum'ı vermeli.
      final out2 = '${Directory.systemTemp.path}/kun_content2.db';
      final rep2 = '${Directory.systemTemp.path}/kun_content_report2.json';
      Process.runSync('python3', [
        'tool/build_content_db.py',
        '--source',
        'assets/fixtures',
        '--out',
        out2,
        '--report',
        rep2,
      ]);
      final second =
          jsonDecode(File(rep2).readAsStringSync()) as Map<String, dynamic>;
      expect(
        second['sha256'],
        digest,
        reason:
            'üretim deterministik olmalı — aksi hâlde checksum '
            'elle düzenlemeyi değil, betiğin kararsızlığını yakalar',
      );
    });

    test('gerçek veri modu (--strict) yer tutucuyu reddeder', () {
      final r = Process.runSync('python3', [
        'tool/build_content_db.py',
        '--source',
        'assets/fixtures',
        '--out',
        '${Directory.systemTemp.path}/kun_strict.db',
        '--strict',
      ], stdoutEncoding: utf8);
      expect(
        r.exitCode,
        isNot(0),
        reason:
            'fixture yer tutucu çevirmen adı ve boş kategori içeriyor; '
            'strict modda build başarısız olmalı',
      );
      expect(r.stdout, contains('BUILD BAŞARISIZ'));
    });
  });
}
