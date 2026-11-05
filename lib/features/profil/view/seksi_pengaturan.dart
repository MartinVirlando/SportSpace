import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../pengaturan/viewmodel/pengaturan_viewmodel.dart';

/// Bagian "Pengaturan" di tab Profil (L-13) — v1.5. Saat ini memuat saklar
/// Pengingat jadwal (T-67, PRD AB-23).
///
/// Membaca [PengaturanViewModel] (Provider global). Pilihannya disimpan di
/// HP, jadi tidak ada kondisi memuat/kosong; kondisi kesalahan dan izin
/// notifikasi ditampilkan sebagai keterangan di bawah saklar.
class SeksiPengaturan extends StatelessWidget {
  const SeksiPengaturan({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PengaturanViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.judulPengaturan, style: AppTextStyles.judulSeksi),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: vm.pengingatAktif,
          onChanged: (nilai) =>
              context.read<PengaturanViewModel>().ubahPengingat(nilai),
          activeThumbColor: AppColors.primary,
          title: const Text(AppStrings.pengingatJadwal),
          subtitle: const Text(
            AppStrings.keteranganPengingat,
            style: AppTextStyles.metaLapangan,
          ),
        ),
        // Saklar menyala tetapi Android belum mengizinkan notifikasi:
        // pengingat tidak akan muncul, dan pengguna perlu tahu kenapa.
        if (vm.pengingatAktif && !vm.izinNotifikasi)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              AppStrings.izinNotifikasiBelum,
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
        if (vm.pesanError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              vm.pesanError!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
