import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/slot_mitra.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/booking_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/atur_slot_viewmodel.dart';

/// Layar Atur Slot (L-19) — PRD AB-17, v1.5 (T-59). BB-67 (blokir), BB-68
/// (buka blokir), BB-69 (jam yang dipesan tidak bisa disentuh).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Dibuka dari tombol "Atur Slot" pada kartu lapangan di Dashboard Mitra
/// (L-14), jadi hanya mitra pemilik lapangan itu yang sampai ke sini.
/// Kepemilikan tetap diperiksa lagi di `BookingRepository` (Security Rules
/// `slotBooking` tidak membatasinya).
class AturSlotScreen extends StatelessWidget {
  final LapanganModel lapangan;

  const AturSlotScreen({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    // Sama seperti layar lain: jaga terhadap `user` yang sudah null (jendela
    // logout) supaya tidak crash lewat `!`.
    final user = context.read<AuthViewModel>().user;
    if (user == null) {
      return Scaffold(
        backgroundColor: context.warna.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider<AturSlotViewModel>(
      create: (context) => AturSlotViewModel(
        repository: context.read<BookingRepository>(),
        lapangan: lapangan,
        mitraId: user.userId,
      ),
      child: const _AturSlotBody(),
    );
  }
}

class _AturSlotBody extends StatelessWidget {
  const _AturSlotBody();

  Future<void> _pilihTanggal(BuildContext context) async {
    final vm = context.read<AturSlotViewModel>();
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: vm.tanggal ?? sekarang,
      firstDate: sekarang,
      lastDate: sekarang.add(const Duration(days: 60)),
    );
    if (hasil != null) await vm.pilihTanggal(hasil);
  }

  Future<void> _tekanJam(BuildContext context, int jam) async {
    final vm = context.read<AturSlotViewModel>();
    final status = vm.statusJam(jam);

    // Hanya jam kosong (blokir) dan jam diblokir (buka) yang bisa ditekan;
    // sisanya sudah dinonaktifkan di chip, ini pengaman kedua.
    final String? error;
    final String pesanSukses;
    if (status == StatusSlotMitra.kosong) {
      error = await vm.blokir(jam);
      pesanSukses = AppStrings.slotBerhasilDiblokir;
    } else if (status == StatusSlotMitra.diblokir) {
      error = await vm.bukaBlokir(jam);
      pesanSukses = AppStrings.slotBerhasilDibuka;
    } else {
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? pesanSukses)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AturSlotViewModel>();

    return Scaffold(
      backgroundColor: context.warna.background,
      appBar: AppBar(
        backgroundColor: context.warna.surface,
        elevation: 0,
        title: Text(
          AppStrings.judulAturSlot,
          style: AppTextStyles.judulSeksi(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(vm.lapangan.nama, style: AppTextStyles.namaLapangan(context)),
              const SizedBox(height: 4),
              Text(
                '${vm.lapangan.jamBuka} – ${vm.lapangan.jamTutup}',
                style: AppTextStyles.metaLapangan(context),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.keteranganAturSlot,
                style: AppTextStyles.metaLapangan(context),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.tanggal, style: AppTextStyles.judulSeksi(context)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pilihTanggal(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: context.warna.surfaceVariant, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vm.tanggal == null
                            ? AppStrings.pilihTanggal
                            : Formatter.tanggal(vm.tanggal!),
                        style: AppTextStyles.namaLapangan(context),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: context.warna.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.jam, style: AppTextStyles.judulSeksi(context)),
              const SizedBox(height: 8),
              _DaftarJam(vm: vm, onTekanJam: (jam) => _tekanJam(context, jam)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Isi bagian jam — tiga kondisi (belum pilih tanggal/memuat/gagal) plus
/// kosong ditangani eksplisit, bukan layar putih polos.
class _DaftarJam extends StatelessWidget {
  final AturSlotViewModel vm;
  final ValueChanged<int> onTekanJam;

  const _DaftarJam({required this.vm, required this.onTekanJam});

  @override
  Widget build(BuildContext context) {
    switch (vm.kondisi) {
      case KondisiAturSlot.belumPilihTanggal:
        return Text(
          AppStrings.pilihTanggalDulu,
          style: AppTextStyles.metaLapangan(context),
        );

      case KondisiAturSlot.memuat:
        return const LinearProgressIndicator();

      case KondisiAturSlot.gagal:
        return Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.errGagalMuat,
                style: AppTextStyles.metaLapangan(context),
              ),
            ),
            TextButton(
              onPressed: context.read<AturSlotViewModel>().muatSlot,
              child: const Text(AppStrings.cobaLagi),
            ),
          ],
        );

      case KondisiAturSlot.berhasil:
        final daftar = vm.daftarJam;
        if (daftar.isEmpty) {
          return Text(
            AppStrings.kosongJamOperasional,
            style: AppTextStyles.metaLapangan(context),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final jam in daftar)
              _ChipJam(
                jam: jam,
                status: vm.statusJam(jam),
                sedangDiproses: vm.sedangDiproses(jam),
                onTap: () => onTekanJam(jam),
              ),
          ],
        );
    }
  }
}

class _ChipJam extends StatelessWidget {
  final int jam;
  final StatusSlotMitra status;
  final bool sedangDiproses;
  final VoidCallback onTap;

  const _ChipJam({
    required this.jam,
    required this.status,
    required this.sedangDiproses,
    required this.onTap,
  });

  /// Jam ≥ 24 = dini hari berikutnya (18:00–02:00 punya jam 24 dan 25);
  /// ditulis `00:00`, `01:00` seperti di L-10.
  String get _label => '${(jam % 24).toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final bisaDitekan = !sedangDiproses &&
        (status == StatusSlotMitra.kosong ||
            status == StatusSlotMitra.diblokir);

    final String teks;
    final Color latar;
    final Color warnaTeks;
    switch (status) {
      case StatusSlotMitra.kosong:
        teks = _label;
        latar = context.warna.surface;
        warnaTeks = context.warna.textPrimary;
      case StatusSlotMitra.diblokir:
        teks = '$_label · ${AppStrings.slotDiblokirLabel}';
        latar = Colors.orange.shade100;
        warnaTeks = Colors.orange.shade900;
      case StatusSlotMitra.dipesan:
        teks = '$_label · ${AppStrings.slotDipesanLabel}';
        latar = context.warna.surfaceVariant;
        warnaTeks = context.warna.textSecondary;
      case StatusSlotMitra.lewat:
        teks = '$_label · ${AppStrings.slotLewatLabel}';
        latar = context.warna.surfaceVariant;
        warnaTeks = context.warna.textSecondary;
    }

    return ActionChip(
      label: sedangDiproses
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(teks),
      avatar: status == StatusSlotMitra.diblokir && !sedangDiproses
          ? Icon(Icons.lock_outline, size: 14, color: warnaTeks)
          : null,
      onPressed: bisaDitekan ? onTap : null,
      backgroundColor: latar,
      disabledColor: latar,
      labelStyle: TextStyle(color: warnaTeks),
    );
  }
}
