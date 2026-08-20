import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Halaman statis generik — PRD L-13, §2.2: "Bantuan, Kebijakan Privasi,
/// Tentang cukup halaman statis", bukan pengaturan yang fungsional.
///
/// ATURAN LAPISAN: tidak menyentuh Firestore sama sekali — [isi] dikirim
/// langsung dari pemanggil (`AppStrings`), bukan dibaca dari mana pun.
class HalamanStatisScreen extends StatelessWidget {
  final String judul;
  final String isi;

  const HalamanStatisScreen({super.key, required this.judul, required this.isi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(judul, style: AppTextStyles.judulSeksi),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          child: Text(
            isi,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
