import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/lapangan_model.dart';
import '../../../models/rating_model.dart';
import '../../../repositories/lapangan_repository.dart';
import '../../../repositories/rating_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../rating/view/beri_rating_sheet.dart';
import '../viewmodel/detail_lapangan_viewmodel.dart';

/// Halaman Detail Lapangan — PRD L-06. BB-11 (tombol reservasi tidak
/// muncul untuk non-mitra), BB-12 (muncul untuk mitra).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Sesuai SPRINT-PLAN T-13, layar ini SENGAJA belum punya:
/// - Badge status "Mitra Terdaftar"/"Terverifikasi" → T-36 (AB-11)
/// - Alur "Ajukan Reservasi" yang sesungguhnya (form L-10) → T-24
///
/// Daftar ulasan (T-22) sudah ada — lewat `StreamBuilder` yang membaca
/// `RatingRepository.streamUlasan()`, mengikuti pola CLAUDE.md aturan 6
/// untuk daftar yang perlu langsung hidup.
///
/// Tombol "Ajukan Reservasi" TETAP digambar (kondisional pada `isMitra`)
/// karena itu justru inti yang diuji BB-11/BB-12 — hanya belum
/// menjalankan apa-apa saat ditekan.
class DetailLapanganScreen extends StatelessWidget {
  final String lapanganId;

  const DetailLapanganScreen({super.key, required this.lapanganId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetailLapanganViewModel>(
      create: (context) => DetailLapanganViewModel(
        repository: context.read<LapanganRepository>(),
        ratingRepository: context.read<RatingRepository>(),
      )..muatDetail(lapanganId),
      child: const _DetailLapanganBody(),
    );
  }
}

class _DetailLapanganBody extends StatelessWidget {
  const _DetailLapanganBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailLapanganViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: switch (vm.kondisi) {
        KondisiDetail.memuat => const _Pemuatan(),
        KondisiDetail.gagal => _Kesalahan(
            pesan: vm.pesanError ?? 'Terjadi kesalahan.',
            onCobaLagi: () => context
                .read<DetailLapanganViewModel>()
                .muatDetail(vm.lapangan?.lapanganId ?? ''),
          ),
        KondisiDetail.berhasil => _Isi(lapangan: vm.lapangan!),
      },
    );
  }
}

class _Pemuatan extends StatelessWidget {
  const _Pemuatan();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _TombolBulat(
              ikon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Kesalahan extends StatelessWidget {
  final String pesan;
  final VoidCallback onCobaLagi;

  const _Kesalahan({required this.pesan, required this.onCobaLagi});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppStrings.errGagalMuat,
                    style: AppTextStyles.judulSeksi,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pesan,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.lokasi,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onCobaLagi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(AppStrings.cobaLagi),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _TombolBulat(
              ikon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  final LapanganModel lapangan;

  const _Isi({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(lapangan: lapangan),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.marginLayar,
              20,
              AppSizes.marginLayar,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lapangan.nama, style: _judulLayar),
                const SizedBox(height: 6),
                Text(_barisRating(lapangan), style: AppTextStyles.lokasi),
                const SizedBox(height: 16),
                _BarisAlamat(lapangan: lapangan),
                const Divider(height: 32),
                _BarisInfo(
                  ikon: '🕐',
                  label: AppStrings.jamBuka,
                  nilai: '${lapangan.jamBuka} – ${lapangan.jamTutup}',
                ),
                const SizedBox(height: 16),
                _BarisInfo(
                  ikon: '💰',
                  label: AppStrings.harga,
                  nilai: '${Formatter.rupiah(lapangan.harga)} / jam',
                ),
                const SizedBox(height: 16),
                _BarisInfo(
                  ikon: '🏟️',
                  label: AppStrings.fasilitas,
                  nilai: lapangan.fasilitas.isEmpty
                      ? '-'
                      : lapangan.fasilitas.join(', '),
                ),
                const SizedBox(height: 16),
                _BarisInfo(
                  ikon: '⚽',
                  label: AppStrings.jenisOlahraga,
                  nilai: lapangan.jenisOlahraga
                      .map(AppSports.labelDari)
                      .join(', '),
                ),
                if (lapangan.isMitra) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // TODO(T-24): buka form Ajukan Reservasi (L-10).
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusChip,
                          ),
                        ),
                      ),
                      child: const Text(AppStrings.ajukanReservasi),
                    ),
                  ),
                ],
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.ulasanPengguna,
                      style: AppTextStyles.judulSeksi,
                    ),
                    TextButton(
                      onPressed: () => _bukaFormRating(context, lapangan),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: const Text(AppStrings.beriRating),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DaftarUlasan(lapanganId: lapangan.lapanganId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _judulLayar = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  String _barisRating(LapanganModel l) {
    if (l.jumlahRating == 0) return AppStrings.belumAdaUlasan;
    return '⭐ ${l.ratingRata2.toStringAsFixed(1)} (${l.jumlahRating} ulasan)';
  }

  /// Membuka modal Beri Rating (L-11, T-21, AB-05/AB-09) dan memuat
  /// ulang detail lapangan sesudahnya supaya `ratingRata2` yang baru
  /// langsung tampil.
  Future<void> _bukaFormRating(BuildContext context, LapanganModel lapangan) async {
    final user = context.read<AuthViewModel>().user;
    if (user == null) return; // AB-09: hanya pengguna yang sudah login

    final berhasil = await showBeriRatingSheet(
      context,
      lapanganId: lapangan.lapanganId,
      userId: user.userId,
      namaUser: user.nama,
    );

    if (berhasil == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.ratingTerkirim)));
      context.read<DetailLapanganViewModel>().muatDetail(lapangan.lapanganId);
    }
  }
}

/// Daftar ulasan lapangan (L-06, T-22) — `StreamBuilder` supaya ulasan
/// baru (mis. setelah T-21 mengirim rating) langsung tampil tanpa
/// menyegarkan layar.
class _DaftarUlasan extends StatelessWidget {
  final String lapanganId;

  const _DaftarUlasan({required this.lapanganId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailLapanganViewModel>();

    return StreamBuilder<List<RatingModel>>(
      stream: vm.streamUlasan(lapanganId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString().replaceFirst('Exception: ', ''),
            style: AppTextStyles.metaLapangan,
          );
        }

        final ulasan = snapshot.data ?? const [];
        if (ulasan.isEmpty) {
          return const Text(
            AppStrings.belumAdaUlasan,
            style: AppTextStyles.metaLapangan,
          );
        }

        return Column(
          children: [
            for (final item in ulasan) ...[
              _KartuUlasan(rating: item),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _KartuUlasan extends StatelessWidget {
  final RatingModel rating;

  const _KartuUlasan({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: AppColors.shadowKartu,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rating.namaUser, style: AppTextStyles.namaLapangan),
              Text(
                Formatter.tanggal(rating.tanggal),
                style: AppTextStyles.metaLapangan,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '⭐' * rating.nilaiRating,
            style: const TextStyle(fontSize: 13),
          ),
          if (rating.ulasanTeks != null && rating.ulasanTeks!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(rating.ulasanTeks!, style: AppTextStyles.metaLapangan),
          ],
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final LapanganModel lapangan;

  const _Hero({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    final olahragaUtama =
        lapangan.jenisOlahraga.isNotEmpty ? lapangan.jenisOlahraga.first : '';

    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (lapangan.fotoURL.isNotEmpty)
            CachedNetworkImage(
              imageUrl: lapangan.fotoURL.first,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceVariant),
              errorWidget: (_, __, ___) =>
                  _BlokWarnaHero(olahraga: olahragaUtama),
            )
          else
            _BlokWarnaHero(olahraga: olahragaUtama),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TombolBulat(
                    ikon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  // TODO(T-35): sambungkan ke FavoritViewModel (AB-10).
                  _TombolBulat(ikon: Icons.favorite_border, onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlokWarnaHero extends StatelessWidget {
  final String olahraga;

  const _BlokWarnaHero({required this.olahraga});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _warnaOlahraga(olahraga),
      alignment: Alignment.center,
      child: Text(
        AppSports.ikonDari(olahraga),
        style: const TextStyle(fontSize: 64),
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

class _TombolBulat extends StatelessWidget {
  final IconData ikon;
  final VoidCallback onTap;

  const _TombolBulat({required this.ikon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(ikon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _BarisAlamat extends StatelessWidget {
  final LapanganModel lapangan;

  const _BarisAlamat({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📍', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(lapangan.alamat, style: AppTextStyles.metaLapangan),
        ),
        // TODO(T-14): buka tab Map terpusat di lapangan ini.
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: const Text('Lihat di peta', style: AppTextStyles.metaLapangan),
        ),
      ],
    );
  }
}

class _BarisInfo extends StatelessWidget {
  final String ikon;
  final String label;
  final String nilai;

  const _BarisInfo({
    required this.ikon,
    required this.label,
    required this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ikon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 14),
        SizedBox(
          width: 90,
          child: Text(label, style: AppTextStyles.metaLapangan),
        ),
        Expanded(
          child: Text(nilai, style: AppTextStyles.namaLapangan),
        ),
      ],
    );
  }
}
