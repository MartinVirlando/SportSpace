import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sports.dart';

/// Baris chip filter olahraga — Home (L-04) dan Cari Rekan (L-07).
///
/// Gaya diambil dari Figma: chip aktif berlatar hijau dengan teks putih,
/// chip non-aktif berlatar putih dengan bayangan tipis.
class BarisChipOlahraga extends StatelessWidget {
  final String terpilih;
  final ValueChanged<String> onPilih;

  const BarisChipOlahraga({
    super.key,
    required this.terpilih,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.marginLayar,
        ),
        itemCount: AppSports.daftarFilter.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final kode = AppSports.daftarFilter[i];
          return _Chip(
            label: '${AppSports.ikonDari(kode)} ${AppSports.labelDari(kode)}',
            aktif: kode == terpilih,
            onTap: () => onPilih(kode),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: aktif ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusChip),
          boxShadow: aktif ? null : AppColors.shadowChip,
        ),
        child: Text(
          label,
          style: AppTextStyles.chip.copyWith(
            color: aktif ? Colors.white : AppColors.textPrimary,
            fontWeight: aktif ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
