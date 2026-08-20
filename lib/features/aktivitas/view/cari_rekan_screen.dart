import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../widgets/chip_olahraga.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/aktivitas_viewmodel.dart';
import 'buat_aktivitas_screen.dart';
import 'detail_aktivitas_screen.dart';

/// Halaman Cari Rekan — PRD L-07. Dibuka dari tab Teman.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Sesuai SPRINT-PLAN T-19, tombol "Gabung" di kartu mengirim permintaan
/// gabung langsung (AB-06, BB-16) lewat [AktivitasViewModel]. Menekan
/// kartu membuka Detail Aktivitas (L-09) — daftar peserta lengkap dan
/// alur Terima/Tolak permintaan (untuk pembuat) ada di sana, baru
/// berfungsi penuh di T-20.
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

  Future<void> _gabung(BuildContext context) async {
    final vm = context.read<AktivitasViewModel>();
    final user = context.read<AuthViewModel>().user;
    if (user == null) return;

    final pesanError = await vm.kirimPermintaanGabung(
      aktivitas,
      userId: user.userId,
      namaUser: user.nama,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesanError ?? AppStrings.permintaanTerkirim),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final warna = _warnaOlahraga(aktivitas.jenisOlahraga);
    final progres = aktivitas.jumlahPemainDibutuhkan == 0
        ? 0.0
        : aktivitas.jumlahPemainSaatIni / aktivitas.jumlahPemainDibutuhkan;

    final userId = context.watch<AuthViewModel>().user?.userId;
    final bisaGabung = userId != null &&
        userId != aktivitas.pembuatId &&
        !aktivitas.peserta.contains(userId);
    final sedangDiproses = context
        .watch<AktivitasViewModel>()
        .sedangDiproses(aktivitas.aktivitasId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: AppColors.shadowKartu,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                DetailAktivitasScreen(aktivitasId: aktivitas.aktivitasId),
          ),
        ),
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
                          if (bisaGabung)
                            ElevatedButton(
                              onPressed: sedangDiproses
                                  ? null
                                  : () => _gabung(context),
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
                              child: sedangDiproses
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
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
