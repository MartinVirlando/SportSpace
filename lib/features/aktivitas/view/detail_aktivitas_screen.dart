import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/permintaan_gabung_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/detail_aktivitas_viewmodel.dart';

/// Halaman Detail Aktivitas — PRD L-09. BB-16 (kirim permintaan gabung).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Sesuai SPRINT-PLAN T-19, tombol **Terima**/**Tolak** pada daftar
/// permintaan masuk SENGAJA belum berfungsi (`onPressed: () {}`) —
/// logikanya (transaction AB-06) baru dikerjakan di T-20, yang juga
/// butuh T-15 (notifikasi) untuk memberi tahu pemohon.
class DetailAktivitasScreen extends StatelessWidget {
  final String aktivitasId;

  const DetailAktivitasScreen({super.key, required this.aktivitasId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetailAktivitasViewModel>(
      create: (context) => DetailAktivitasViewModel(
        repository: context.read<AktivitasRepository>(),
        aktivitasId: aktivitasId,
      ),
      child: const _DetailAktivitasBody(),
    );
  }
}

class _DetailAktivitasBody extends StatelessWidget {
  const _DetailAktivitasBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailAktivitasViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.detailAktivitas,
          style: AppTextStyles.judulSeksi,
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<AktivitasBermainModel>(
          stream: vm.streamAktivitas,
          builder: (context, snapAktivitas) {
            if (snapAktivitas.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapAktivitas.hasError) {
              return _Pesan(
                ikon: Icons.error_outline,
                judul: AppStrings.errGagalMuat,
                keterangan: snapAktivitas.error
                    .toString()
                    .replaceFirst('Exception: ', ''),
              );
            }

            final aktivitas = snapAktivitas.data;
            if (aktivitas == null) {
              return const _Pesan(
                ikon: Icons.error_outline,
                judul: AppStrings.errGagalMuat,
                keterangan: '',
              );
            }

            return StreamBuilder<List<PermintaanGabungModel>>(
              stream: vm.streamPermintaan,
              builder: (context, snapPermintaan) {
                final permintaan = snapPermintaan.data ?? const [];
                return _Isi(aktivitas: aktivitas, permintaan: permintaan);
              },
            );
          },
        ),
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  final AktivitasBermainModel aktivitas;
  final List<PermintaanGabungModel> permintaan;

  const _Isi({required this.aktivitas, required this.permintaan});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final apakahPembuat = user != null && user.userId == aktivitas.pembuatId;

    final pesertaDiterima =
        permintaan.where((p) => p.status == 'DITERIMA').toList();
    final permintaanMenunggu =
        permintaan.where((p) => p.status == 'MENUNGGU').toList();

    final progres = aktivitas.jumlahPemainDibutuhkan == 0
        ? 0.0
        : aktivitas.jumlahPemainSaatIni / aktivitas.jumlahPemainDibutuhkan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.marginLayar),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppSports.ikonDari(aktivitas.jenisOlahraga),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppSports.labelDari(aktivitas.jenisOlahraga),
                      style: AppTextStyles.sambutan,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '📍 ${aktivitas.namaLapangan}',
                      style: AppTextStyles.metaLapangan,
                    ),
                    Text(
                      '🕐 ${Formatter.tanggalDanJam(aktivitas.waktu)}',
                      style: AppTextStyles.metaLapangan,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (aktivitas.catatan != null && aktivitas.catatan!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(aktivitas.catatan!, style: AppTextStyles.namaLapangan),
          ],
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progres.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${aktivitas.jumlahPemainSaatIni}/'
            '${aktivitas.jumlahPemainDibutuhkan} pemain',
            style: AppTextStyles.metaLapangan,
          ),
          const Divider(height: 32),
          const Text(AppStrings.daftarPeserta, style: AppTextStyles.judulSeksi),
          const SizedBox(height: 10),
          _BarisPeserta(nama: aktivitas.namaPembuat, pembuat: true),
          for (final p in pesertaDiterima)
            _BarisPeserta(nama: p.namaUser, pembuat: false),
          const Divider(height: 32),
          if (apakahPembuat)
            _SeksiPermintaanMasuk(
              aktivitas: aktivitas,
              permintaan: permintaanMenunggu,
            )
          else
            _AksiGabung(
              aktivitas: aktivitas,
              permintaanSaya: _cariPermintaanSaya(permintaan, user?.userId),
            ),
        ],
      ),
    );
  }
}

PermintaanGabungModel? _cariPermintaanSaya(
  List<PermintaanGabungModel> permintaan,
  String? userId,
) {
  if (userId == null) return null;
  for (final p in permintaan) {
    if (p.userId == userId) return p;
  }
  return null;
}

class _BarisPeserta extends StatelessWidget {
  final String nama;
  final bool pembuat;

  const _BarisPeserta({required this.nama, required this.pembuat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.surfaceVariant,
            child: Icon(Icons.person, size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 10),
          Text(nama, style: AppTextStyles.namaLapangan),
          if (pembuat) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusChip),
              ),
              child: const Text(
                AppStrings.pembuatAktivitas,
                style: TextStyle(fontSize: 10, color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ditampilkan kalau pengguna yang membuka layar ini adalah pembuat
/// aktivitas — daftar permintaan MENUNGGU dengan tombol Terima/Tolak
/// (PRD L-09, T-20).
class _SeksiPermintaanMasuk extends StatelessWidget {
  final AktivitasBermainModel aktivitas;
  final List<PermintaanGabungModel> permintaan;

  const _SeksiPermintaanMasuk({
    required this.aktivitas,
    required this.permintaan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.permintaanMasuk, style: AppTextStyles.judulSeksi),
        const SizedBox(height: 10),
        if (permintaan.isEmpty)
          const Text(
            AppStrings.kosongPermintaan,
            style: AppTextStyles.metaLapangan,
          )
        else
          for (final p in permintaan)
            _BarisPermintaan(aktivitas: aktivitas, permintaan: p),
      ],
    );
  }
}

/// Satu baris permintaan gabung dengan tombol Terima/Tolak — PRD AB-06,
/// T-20, BB-17/BB-18/BB-19.
///
/// StatefulWidget lokal (bukan lewat [DetailAktivitasViewModel.sedangProses])
/// supaya menekan Terima/Tolak di satu baris tidak mengunci tombol baris
/// lain — daftar permintaan MENUNGGU bisa lebih dari satu.
class _BarisPermintaan extends StatefulWidget {
  final AktivitasBermainModel aktivitas;
  final PermintaanGabungModel permintaan;

  const _BarisPermintaan({required this.aktivitas, required this.permintaan});

  @override
  State<_BarisPermintaan> createState() => _BarisPermintaanState();
}

class _BarisPermintaanState extends State<_BarisPermintaan> {
  bool _sedangProses = false;

  Future<void> _terima() async {
    setState(() => _sedangProses = true);
    final vm = context.read<DetailAktivitasViewModel>();
    final error = await vm.terimaPermintaan(
      userId: widget.permintaan.userId,
      namaUser: widget.permintaan.namaUser,
    );

    if (!mounted) return;
    setState(() => _sedangProses = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? '${widget.permintaan.namaUser} diterima bergabung.',
        ),
      ),
    );
  }

  Future<void> _tolak() async {
    setState(() => _sedangProses = true);
    final vm = context.read<DetailAktivitasViewModel>();
    final error = await vm.tolakPermintaan(
      userId: widget.permintaan.userId,
      namaUser: widget.permintaan.namaUser,
      namaLapangan: widget.aktivitas.namaLapangan,
    );

    if (!mounted) return;
    setState(() => _sedangProses = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Permintaan ${widget.permintaan.namaUser} ditolak.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.permintaan.namaUser,
              style: AppTextStyles.namaLapangan,
            ),
          ),
          if (_sedangProses)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            TextButton(
              onPressed: _tolak,
              child: const Text(AppStrings.tolak),
            ),
            ElevatedButton(
              onPressed: _terima,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.terima),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ditampilkan untuk pengguna yang BUKAN pembuat aktivitas — tombol
/// "Gabung", atau label status permintaannya sendiri (PRD L-09).
class _AksiGabung extends StatefulWidget {
  final AktivitasBermainModel aktivitas;
  final PermintaanGabungModel? permintaanSaya;

  const _AksiGabung({required this.aktivitas, required this.permintaanSaya});

  @override
  State<_AksiGabung> createState() => _AksiGabungState();
}

class _AksiGabungState extends State<_AksiGabung> {
  Future<void> _gabung(UserModel user) async {
    final vm = context.read<DetailAktivitasViewModel>();
    final berhasil = await vm.kirimPermintaanGabung(
      widget.aktivitas,
      userId: user.userId,
      namaUser: user.nama,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? AppStrings.permintaanTerkirim
              : (vm.pesanError ?? 'Gagal mengirim permintaan.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final vm = context.watch<DetailAktivitasViewModel>();

    if (user == null) return const SizedBox.shrink();

    final sudahJadiPeserta = widget.aktivitas.peserta.contains(user.userId);
    if (sudahJadiPeserta) {
      return const _LabelStatus(
        ikon: Icons.check_circle,
        teks: AppStrings.sudahBergabung,
      );
    }

    if (widget.permintaanSaya?.status == 'MENUNGGU') {
      return const _LabelStatus(
        ikon: Icons.hourglass_top,
        teks: AppStrings.menungguPersetujuan,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: vm.sedangProses ? null : () => _gabung(user),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusChip),
          ),
        ),
        child: vm.sedangProses
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(AppStrings.gabung),
      ),
    );
  }
}

class _LabelStatus extends StatelessWidget {
  final IconData ikon;
  final String teks;

  const _LabelStatus({required this.ikon, required this.teks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(teks, style: AppTextStyles.namaLapangan),
        ],
      ),
    );
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
