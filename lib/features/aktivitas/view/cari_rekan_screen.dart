import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../widgets/chip_olahraga.dart';
import '../viewmodel/aktivitas_viewmodel.dart';
import 'buat_aktivitas_screen.dart';

/// Halaman Cari Rekan — PRD L-07. Dibuka dari tab Teman.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Sesuai SPRINT-PLAN T-17, layar ini masih SENGAJA belum punya alur
/// "Gabung" sungguhan (kirim permintaan, AB-06) → T-19/T-20. Tombol
/// tetap digambar per kartu (sesuai PRD), belum berfungsi.
class CariRekanScreen extends StatelessWidget {
  const CariRekanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AktivitasViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BuatAktivitasScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const SizedBox(height: 10),
            BarisChipOlahraga(
              terpilih: vm.filterOlahraga,
              onPilih: context.read<AktivitasViewModel>().ubahFilterOlahraga,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<List<AktivitasBermainModel>>(
                stream: vm.streamAktivitas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _Pesan(
                      ikon: Icons.error_outline,
                      judul: AppStrings.errGagalMuat,
                      keterangan: snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                    );
                  }

                  final daftar = snapshot.data ?? const [];
                  if (daftar.isEmpty) {
                    return const _Pesan(
                      ikon: Icons.people_outline,
                      judul: AppStrings.kosongAktivitas,
                      keterangan: '',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.marginLayar,
                      0,
                      AppSizes.marginLayar,
                      16,
                    ),
                    itemCount: daftar.length,
                    itemBuilder: (context, i) =>
                        _KartuAktivitas(aktivitas: daftar[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        12,
        AppSizes.marginLayar,
        12,
      ),
      child: const Text(AppStrings.cariRekan, style: AppTextStyles.sambutan),
    );
  }
}

class _KartuAktivitas extends StatelessWidget {
  final AktivitasBermainModel aktivitas;

  const _KartuAktivitas({required this.aktivitas});

  @override
  Widget build(BuildContext context) {
    final warna = _warnaOlahraga(aktivitas.jenisOlahraga);
    final progres = aktivitas.jumlahPemainDibutuhkan == 0
        ? 0.0
        : aktivitas.jumlahPemainSaatIni / aktivitas.jumlahPemainDibutuhkan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: AppColors.shadowKartu,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: warna),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppSports.ikonDari(aktivitas.jenisOlahraga),
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${aktivitas.namaPembuat} · '
                                '${AppSports.labelDari(aktivitas.jenisOlahraga)}',
                                style: AppTextStyles.namaLapangan,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '📍 ${aktivitas.namaLapangan}',
                                style: AppTextStyles.metaLapangan,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '🕐 ${Formatter.tanggalDanJam(aktivitas.waktu)}',
                                style: AppTextStyles.metaLapangan,
                              ),
                            ],
                          ),
                        ),
                        // TODO(T-19): kirim permintaan gabung (AB-06).
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusChip,
                              ),
                            ),
                          ),
                          child: const Text(
                            AppStrings.gabung,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progres.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(warna),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${aktivitas.jumlahPemainSaatIni}/'
                      '${aktivitas.jumlahPemainDibutuhkan} pemain',
                      style: AppTextStyles.metaLapangan,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _warnaOlahraga(String kode) {
    switch (kode) {
      case AppSports.futsal:
        return AppColors.futsal;
      case AppSports.badminton:
        return AppColors.badminton;
      case AppSports.padel:
        return AppColors.padel;
      case AppSports.miniSoccer:
        return AppColors.miniSoccer;
      default:
        return AppColors.surfaceVariant;
    }
  }
}

class _Pesan extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String keterangan;

  const _Pesan({
    required this.ikon,
    required this.judul,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              judul,
              style: AppTextStyles.judulSeksi,
              textAlign: TextAlign.center,
            ),
            if (keterangan.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                keterangan,
                textAlign: TextAlign.center,
                style: AppTextStyles.lokasi,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
