import 'package:flutter/material.dart';

import '../core/constants/app_aktivitas.dart';
import '../core/constants/app_colors.dart';
import '../models/aktivitas_bermain_model.dart';

/// Deretan label kecil di kartu Cari Rekan (L-07) dan Detail Aktivitas
/// (L-09): jenis aktivitas (T-54), tingkat kemampuan (T-55), dan nanti biaya
/// per orang (T-56). Label yang datanya tidak ada (mis. tingkat pada
/// aktivitas lama) tidak ditampilkan.
class BarisLabelAktivitas extends StatelessWidget {
  final AktivitasBermainModel aktivitas;

  const BarisLabelAktivitas({super.key, required this.aktivitas});

  @override
  Widget build(BuildContext context) {
    final tingkat = aktivitas.tingkatKemampuan;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        LabelAktivitas(
          teks: AppJenisAktivitas.labelDari(aktivitas.jenisAktivitas),
        ),
        if (tingkat != null)
          LabelAktivitas(teks: AppTingkat.labelDari(tingkat)),
      ],
    );
  }
}

/// Satu label berbentuk pil. Gayanya meniru label "Pembuat" di Detail
/// Aktivitas: latar hijau tipis, teks hijau kecil.
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
