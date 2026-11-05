import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fasilitas.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/urut_lapangan.dart';
import '../viewmodel/home_viewmodel.dart';

/// Lembar bawah "Filter & Urutkan" di Home — PRD L-04, AB-16, T-57.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini. Lembar
/// ini tidak membaca data apa pun; ia hanya mengubah state
/// [HomeViewModel], yang menyaring dan mengurutkan di klien.
///
/// `HomeViewModel` adalah Provider global (`main.dart`), jadi aman dibaca
/// dari dalam lembar bawah yang dibuka di atas Navigator. Perubahan terasa
/// langsung: daftar di belakang lembar ikut berubah selagi lembar terbuka.
Future<void> showLembarFilterLapangan(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.warna.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _LembarFilterBody(),
  );
}

/// Teks pilihan urutan. `enum` tidak membawa teks tampilan (teks antarmuka
/// wajib di `AppStrings`), jadi pemetaannya di sini.
const _labelUrutan = {
  UrutanLapangan.terdekat: AppStrings.urutTerdekat,
  UrutanLapangan.rating: AppStrings.urutRating,
  UrutanLapangan.populer: AppStrings.urutPopuler,
};

class _LembarFilterBody extends StatelessWidget {
  const _LembarFilterBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSizes.marginLayar,
          16,
          AppSizes.marginLayar,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.filterUrutkan,
                  style: AppTextStyles.judulSeksi(context),
                ),
                TextButton(
                  onPressed: vm.adaFilterLanjutan
                      ? context.read<HomeViewModel>().resetFilterLanjutan
                      : null,
                  child: const Text(AppStrings.resetFilter),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(AppStrings.urutkan, style: AppTextStyles.namaLapangan(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: UrutanLapangan.values.map((urutan) {
                final aktif = urutan == vm.urutan;
                return ChoiceChip(
                  label: Text(_labelUrutan[urutan]!),
                  selected: aktif,
                  onSelected: (_) =>
                      context.read<HomeViewModel>().ubahUrutan(urutan),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: aktif ? Colors.white : context.warna.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppStrings.bukaSekarang,
                style: AppTextStyles.namaLapangan(context),
              ),
              subtitle: Text(
                AppStrings.keteranganBukaSekarang,
                style: AppTextStyles.metaLapangan(context),
              ),
              value: vm.bukaSekarang,
              activeThumbColor: AppColors.primary,
              onChanged: context.read<HomeViewModel>().ubahBukaSekarang,
            ),
            const SizedBox(height: 8),
            Text(AppStrings.fasilitas, style: AppTextStyles.namaLapangan(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: AppFasilitas.daftar.map((f) {
                final aktif = vm.fasilitasDipilih.contains(f);
                return FilterChip(
                  label: Text(f),
                  selected: aktif,
                  onSelected: (_) =>
                      context.read<HomeViewModel>().ubahFasilitas(f),
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: aktif ? Colors.white : context.warna.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                  ),
                ),
                child: const Text(AppStrings.tampilkanHasil),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
