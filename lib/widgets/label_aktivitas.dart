import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Label kecil berbentuk pil di kartu dan Detail Aktivitas — dipakai untuk
/// jenis aktivitas (T-54), nanti juga tingkat kemampuan (T-55) dan biaya
/// (T-56). Gayanya meniru label "Pembuat" di Detail Aktivitas: latar hijau
/// tipis, teks hijau kecil.
class LabelAktivitas extends StatelessWidget {
  final String teks;

  const LabelAktivitas({super.key, required this.teks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Text(
        teks,
        style: const TextStyle(fontSize: 10, color: AppColors.primary),
      ),
    );
  }
}
