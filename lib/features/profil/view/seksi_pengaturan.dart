import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/mode_tema.dart';
import '../../pengaturan/viewmodel/pengaturan_viewmodel.dart';

/// Bagian "Pengaturan" di tab Profil (L-13) — v1.5. Memuat pemilih Mode
/// tampilan (AB-24) dan saklar Pengingat jadwal (T-67, AB-23).
///
/// Membaca [PengaturanViewModel] (Provider global). Pilihannya disimpan di
/// HP, jadi tidak ada kondisi memuat/kosong; kondisi kesalahan dan izin
/// notifikasi ditampilkan sebagai keterangan di bawah kontrolnya.
class SeksiPengaturan extends StatelessWidget {
  const SeksiPengaturan({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PengaturanViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.judulPengaturan,
          style: AppTextStyles.judulSeksi(context),
        ),
        const SizedBox(height: 12),
        // ---------- Mode tampilan (AB-24) ----------
        Text(
          AppStrings.modeTampilan,
          style: AppTextStyles.namaLapangan(context),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ModeTema>(
            // Tiga pilihan, tepat satu terpilih. Tanpa ini SegmentedButton
            // membolehkan "tidak ada yang terpilih".
            emptySelectionAllowed: false,
            multiSelectionEnabled: false,
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ModeTema.terang,
                label: Text(AppStrings.modeTerang),
                icon: Icon(Icons.light_mode_outlined, size: 18),
              ),
              ButtonSegment(
                value: ModeTema.gelap,
                label: Text(AppStrings.modeGelap),
                icon: Icon(Icons.dark_mode_outlined, size: 18),
              ),
              ButtonSegment(
                value: ModeTema.sistem,
                label: Text(AppStrings.modeSistem),
                icon: Icon(Icons.brightness_auto_outlined, size: 18),
              ),
            ],
            selected: {vm.modeTema},
            onSelectionChanged: (pilihan) =>
                context.read<PengaturanViewModel>().ubahModeTema(pilihan.first),
          ),
        ),
        if (vm.pesanErrorTema != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              vm.pesanErrorTema!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        const SizedBox(height: 12),
        // ---------- Pengingat jadwal (T-67) ----------
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: vm.pengingatAktif,
          onChanged: (nilai) =>
              context.read<PengaturanViewModel>().ubahPengingat(nilai),
          activeThumbColor: AppColors.primary,
          title: const Text(AppStrings.pengingatJadwal),
          subtitle: Text(
            AppStrings.keteranganPengingat,
            style: AppTextStyles.metaLapangan(context),
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
