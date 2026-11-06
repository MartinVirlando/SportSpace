import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_aktivitas.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../viewmodel/aktivitas_viewmodel.dart';

/// Lembar bawah "Filter Aktivitas" di Cari Rekan (L-07) — memuat filter jenis
/// aktivitas (T-54) dan tingkat kemampuan (T-55). Filter olahraga tetap
/// berupa chip di layar utama.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini; lembar ini
/// hanya mengubah state [AktivitasViewModel].
///
/// KENAPA [vm] DIOPER LEWAT PARAMETER: `AktivitasViewModel` dipasang di
/// dalam tab Teman (`app_routes.dart`), bukan di atas seluruh aplikasi.
/// `showModalBottomSheet` membangun lembarnya di bawah Navigator utama,
/// yang letaknya DI ATAS tab itu — jadi `context.read<AktivitasViewModel>()`
/// dari dalam lembar tidak akan menemukannya. `ChangeNotifierProvider.value`
/// memasang objek yang sudah ada (tidak membuat baru, dan tidak membuangnya
/// saat lembar ditutup) ke dalam lembar.
Future<void> showLembarFilterAktivitas(
  BuildContext context,
  AktivitasViewModel vm,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.warna.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => ChangeNotifierProvider<AktivitasViewModel>.value(
      value: vm,
      child: const _LembarFilterBody(),
    ),
  );
}

class _LembarFilterBody extends StatelessWidget {
  const _LembarFilterBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AktivitasViewModel>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.marginLayar,
          16,
          AppSizes.marginLayar,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.filterAktivitas,
                  style: AppTextStyles.judulSeksi(context),
                ),
                TextButton(
                  onPressed: vm.adaFilterLanjutan
                      ? context.read<AktivitasViewModel>().resetFilterLanjutan
                      : null,
                  child: const Text(AppStrings.resetFilter),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SeksiPilihan(
              judul: AppStrings.jenisAktivitas,
              daftarKode: AppJenisAktivitas.daftarFilter,
              label: AppJenisAktivitas.label,
              terpilih: vm.filterJenis,
              onPilih: context.read<AktivitasViewModel>().ubahFilterJenis,
            ),
            const SizedBox(height: 16),
            _SeksiPilihan(
              judul: AppStrings.tingkatKemampuan,
              daftarKode: AppTingkat.daftarFilter,
              label: AppTingkat.label,
              terpilih: vm.filterTingkat,
              onPilih: context.read<AktivitasViewModel>().ubahFilterTingkat,
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

/// Satu seksi: judul kecil + deretan chip pilihan tunggal. Dipakai dua kali
/// (jenis dan tingkat) supaya tidak menulis chip yang sama dua kali.
class _SeksiPilihan extends StatelessWidget {
  final String judul;
  final List<String> daftarKode;
  final Map<String, String> label;
  final String terpilih;
  final ValueChanged<String> onPilih;

  const _SeksiPilihan({
    required this.judul,
    required this.daftarKode,
    required this.label,
    required this.terpilih,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul, style: AppTextStyles.namaLapangan(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: daftarKode.map((kode) {
            final aktif = kode == terpilih;
            return ChoiceChip(
              label: Text(label[kode] ?? kode),
              selected: aktif,
              onSelected: (_) => onPilih(kode),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: aktif ? Colors.white : context.warna.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
