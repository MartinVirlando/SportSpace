import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_colors.dart';
import 'package:sport_space/core/theme/app_theme.dart';
import 'package:sport_space/core/theme/mode_tema.dart';

/// Uji otomatis untuk mode gelap — PRD AB-24, v1.5, BB-96…BB-100.

/// Kecerahan relatif sebuah warna menurut WCAG 2.1.
double _kecerahan(Color c) {
  double kanal(double nilai) => nilai <= 0.03928
      ? nilai / 12.92
      : math.pow((nilai + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * kanal(c.r) + 0.7152 * kanal(c.g) + 0.0722 * kanal(c.b);
}

/// Rasio kontras dua warna (1 sampai 21). WCAG AA: teks biasa minimal 4,5.
double _kontras(Color a, Color b) {
  final terang = math.max(_kecerahan(a), _kecerahan(b));
  final gelap = math.min(_kecerahan(a), _kecerahan(b));
  return (terang + 0.05) / (gelap + 0.05);
}

void main() {
  group('ModeTema', () {
    test('kode yang disimpan dibaca kembali menjadi mode yang sama', () {
      for (final mode in ModeTema.values) {
        expect(ModeTema.dariKode(mode.kode), mode);
      }
    });

    test('nilai kosong atau tidak dikenal jatuh ke bawaan TERANG (BB-96)', () {
      expect(ModeTema.dariKode(null), ModeTema.terang);
      expect(ModeTema.dariKode(''), ModeTema.terang);
      expect(ModeTema.dariKode('ungu'), ModeTema.terang);
      expect(ModeTema.dariKode('GELAP'), ModeTema.terang); // huruf besar: tidak dikenal
    });

    test('kode tiap mode berbeda dan tidak kosong', () {
      final kode = ModeTema.values.map((m) => m.kode).toSet();
      expect(kode, hasLength(ModeTema.values.length));
      expect(kode.every((k) => k.isNotEmpty), isTrue);
    });

    test('pemetaan ke ThemeMode Flutter benar', () {
      expect(AppTheme.themeModeDari(ModeTema.terang), ThemeMode.light);
      expect(AppTheme.themeModeDari(ModeTema.gelap), ThemeMode.dark);
      expect(AppTheme.themeModeDari(ModeTema.sistem), ThemeMode.system);
    });
  });

  group('AppPalette.terang — tampilan terang tidak berubah (BB-97)', () {
    test('nilainya sama persis dengan konstanta Figma yang lama', () {
      const p = AppPalette.terang;
      expect(p.background, const Color(0xFFF8F8F8));
      expect(p.surface, const Color(0xFFFFFFFF));
      expect(p.surfaceVariant, const Color(0xFFF2F2F2));
      expect(p.textPrimary, const Color(0xFF1C1C1C));
      expect(p.textSecondary, const Color(0xFF8C8C8C));
      expect(p.textTertiary, const Color(0xFF4D4D4D));
      expect(p.mapBackground, const Color(0xFFD8E9D8));
      expect(p.mapGrid, const Color(0x80B2D9B2));
      expect(p.shadowKartu, hasLength(1));
      expect(p.shadowKartu.single.color, const Color(0x14000000));
      expect(p.shadowChip, hasLength(1));
      expect(p.shadowChip.single.color, const Color(0x0F000000));
    });

    test('hijau merek sama di kedua mode', () {
      expect(AppColors.primary, const Color(0xFF1FA54E));
    });
  });

  group('AppPalette.gelap — kontras teks (BB-98)', () {
    const p = AppPalette.gelap;
    final latar = {
      'background': p.background,
      'surface': p.surface,
      'surfaceVariant': p.surfaceVariant,
    };

    test('teks utama minimal 7:1 (WCAG AAA) di atas semua latar', () {
      latar.forEach((nama, warna) {
        expect(
          _kontras(p.textPrimary, warna),
          greaterThanOrEqualTo(7),
          reason: 'textPrimary di atas $nama',
        );
      });
    });

    test('teks sekunder minimal 4,5:1 (WCAG AA) di atas semua latar', () {
      latar.forEach((nama, warna) {
        expect(
          _kontras(p.textSecondary, warna),
          greaterThanOrEqualTo(4.5),
          reason: 'textSecondary di atas $nama',
        );
      });
    });

    test('hijau merek terbaca (minimal 3:1) di atas permukaan', () {
      expect(_kontras(AppColors.primary, p.surface), greaterThanOrEqualTo(3));
      expect(_kontras(AppColors.primary, p.background), greaterThanOrEqualTo(3));
    });

    test('permukaan lebih terang dari latar, supaya kartu terlihat terpisah', () {
      expect(_kecerahan(p.surface), greaterThan(_kecerahan(p.background)));
      expect(_kecerahan(p.surfaceVariant), greaterThan(_kecerahan(p.surface)));
    });

    test('bayangan dikosongkan (tidak terlihat di latar gelap)', () {
      expect(p.shadowKartu, isEmpty);
      expect(p.shadowChip, isEmpty);
    });
  });

  group('AppPalette.lerp', () {
    test('t=0 menghasilkan palet awal dan t=1 palet tujuan', () {
      final awal = AppPalette.terang.lerp(AppPalette.gelap, 0);
      final akhir = AppPalette.terang.lerp(AppPalette.gelap, 1);
      expect(awal.surface, AppPalette.terang.surface);
      expect(akhir.surface, AppPalette.gelap.surface);
      expect(akhir.textPrimary, AppPalette.gelap.textPrimary);
    });

    test('daftar bayangan beda panjang (1 vs kosong) tidak menyebabkan galat', () {
      expect(
        () => AppPalette.terang.lerp(AppPalette.gelap, 0.5),
        returnsNormally,
      );
      expect(
        () => AppPalette.gelap.lerp(AppPalette.terang, 0.5),
        returnsNormally,
      );
    });

    test('lerp dengan objek lain mengembalikan dirinya sendiri', () {
      expect(AppPalette.terang.lerp(null, 0.5), same(AppPalette.terang));
    });

    test('copyWith mengganti hanya yang diminta', () {
      final p = AppPalette.terang.copyWith(surface: const Color(0xFF123456));
      expect(p.surface, const Color(0xFF123456));
      expect(p.background, AppPalette.terang.background);
    });
  });

  group('AppTheme', () {
    test('kedua tema membawa AppPalette yang sesuai', () {
      expect(
        AppTheme.terang().extension<AppPalette>(),
        same(AppPalette.terang),
      );
      expect(
        AppTheme.gelap().extension<AppPalette>(),
        same(AppPalette.gelap),
      );
    });

    test('kecerahan tema sesuai namanya', () {
      expect(AppTheme.terang().brightness, Brightness.light);
      expect(AppTheme.gelap().brightness, Brightness.dark);
    });

    test('ThemeData dibuat sekali (objek yang sama tiap dipanggil)', () {
      expect(identical(AppTheme.terang(), AppTheme.terang()), isTrue);
      expect(identical(AppTheme.gelap(), AppTheme.gelap()), isTrue);
    });

    test('latar layar mengikuti palet', () {
      expect(
        AppTheme.terang().scaffoldBackgroundColor,
        AppPalette.terang.background,
      );
      expect(
        AppTheme.gelap().scaffoldBackgroundColor,
        AppPalette.gelap.background,
      );
    });
  });

  group('context.warna', () {
    testWidgets('mengikuti tema yang aktif dan berganti saat tema berganti (BB-99)',
        (tester) async {
      Color? terbaca;
      Widget bangun(ThemeMode mode) => MaterialApp(
            theme: AppTheme.terang(),
            darkTheme: AppTheme.gelap(),
            themeMode: mode,
            home: Builder(
              builder: (context) {
                terbaca = context.warna.surface;
                return Text(
                  'x',
                  style: AppTextStyles.judulSeksi(context),
                );
              },
            ),
          );

      await tester.pumpWidget(bangun(ThemeMode.light));
      expect(terbaca, AppPalette.terang.surface);

      await tester.pumpWidget(bangun(ThemeMode.dark));
      await tester.pumpAndSettle();
      expect(terbaca, AppPalette.gelap.surface);
    });

    testWidgets('gaya teks mengambil warna dari palet aktif', (tester) async {
      TextStyle? gaya;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.gelap(),
          home: Builder(
            builder: (context) {
              gaya = AppTextStyles.metaLapangan(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(gaya!.color, AppPalette.gelap.textSecondary);
      expect(gaya!.fontSize, 10); // ukuran dari Figma tidak berubah
    });

    testWidgets('tema tanpa AppPalette jatuh ke terang, bukan crash',
        (tester) async {
      Color? terbaca;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(), // sengaja tanpa extension
          home: Builder(
            builder: (context) {
              terbaca = context.warna.background;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(terbaca, AppPalette.terang.background);
    });
  });
}
