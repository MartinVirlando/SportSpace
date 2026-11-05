import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_aktivitas.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../widgets/baris_chip_filter.dart';
import '../../../widgets/chip_olahraga.dart';
import '../../../widgets/label_aktivitas.dart';
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
            const SizedBox(height: 8),
            // v1.4 (T-54) — filter jenis aktivitas, disaring di klien.
            BarisChipFilter(
              daftarKode: AppJenisAktivitas.daftarFilter,
              label: AppJenisAktivitas.label,
              terpilih: vm.filterJenis,
              onPilih: context.read<AktivitasViewModel>().ubahFilterJenis,
            ),
            const SizedBox(height: 8),
            // v1.4 (T-55) — filter tingkat kemampuan, disaring di klien.
            BarisChipFilter(
              daftarKode: AppTingkat.daftarFilter,
              label: AppTingkat.label,
              terpilih: vm.filterTingkat,
              onPilih: context.read<AktivitasViewModel>().ubahFilterTingkat,
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

                  final semua = snapshot.data ?? const [];
                  if (semua.isEmpty) {
                    return const _Pesan(
                      ikon: Icons.people_outline,
                      judul: AppStrings.kosongAktivitas,
                      keterangan: '',
                    );
                  }

                  // Filter klien (T-54): daftar dari Firestore ada isinya,
                  // tapi bisa jadi tidak ada yang cocok dengan chip jenis.
                  final daftar = vm.saring(semua);
                  if (daftar.isEmpty) {
                    // Kalau pengguna belum memilih filter jenis/tingkat,
                    // daftar kosong bukan karena filter — mis. satu-satunya
                    // aktivitas adalah yang PRIVAT (T-64), yang memang
                    // disembunyikan. Pesannya jangan menyalahkan filter.
                    final adaFilterAktif =
                        vm.filterJenis != AppJenisAktivitas.semua ||
                            vm.filterTingkat != AppTingkat.semua;
                    return _Pesan(
                      ikon: adaFilterAktif
                          ? Icons.filter_alt_off_outlined
                          : Icons.people_outline,
                      judul: adaFilterAktif
                          ? AppStrings.kosongFilterAktivitas
                          : AppStrings.kosongAktivitas,
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
  /// Dialog isian kode akses aktivitas privat — PRD AB-21, T-64, BB-80/81.
  Future<void> _bukaDenganKode(BuildContext context) async {
    final vm = context.read<AktivitasViewModel>();
    final kode = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogKode(),
    );
    if (kode == null || !context.mounted) return;

    try {
      final aktivitas = await vm.cariAktivitasByKode(kode);
      if (!context.mounted) return;

      if (aktivitas == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.kodeTidakDitemukan)),
        );
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              DetailAktivitasScreen(aktivitasId: aktivitas.aktivitasId),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

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
      child: Row(
        children: [
          const Expanded(
            child: Text(AppStrings.cariRekan, style: AppTextStyles.sambutan),
          ),
          // v1.5 (T-64): buka aktivitas privat lewat kode.
          TextButton.icon(
            onPressed: () => _bukaDenganKode(context),
            icon: const Icon(Icons.vpn_key_outlined, size: 16),
            label: const Text(AppStrings.punyaKode),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog isian kode akses. Mengembalikan teks mentah yang diketik (sudah
/// di-`trim`), atau `null` kalau dibatalkan atau dikosongkan.
///
/// StatefulWidget karena `TextEditingController` harus dibuang saat dialog
/// ditutup — bukan di `StatelessWidget`, yang tidak punya `dispose`.
class _DialogKode extends StatefulWidget {
  const _DialogKode();

  @override
  State<_DialogKode> createState() => _DialogKodeState();
}

class _DialogKodeState extends State<_DialogKode> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _kirim() {
    final teks = _ctrl.text.trim();
    Navigator.of(context).pop(teks.isEmpty ? null : teks);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.judulMasukkanKode),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(hintText: AppStrings.hintKode),
        onSubmitted: (_) => _kirim(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.batal),
        ),
        TextButton(
          onPressed: _kirim,
          child: const Text(AppStrings.bukaAktivitas),
        ),
      ],
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
                                const SizedBox(height: 6),
                                BarisLabelAktivitas(aktivitas: aktivitas),
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
                        '${aktivitas.jumlahPemainDibutuhkan} ${AppStrings.satuanPemain}',
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
