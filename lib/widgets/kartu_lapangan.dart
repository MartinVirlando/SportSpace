import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sports.dart';
import '../core/utils/formatter.dart';
import '../models/lapangan_model.dart';

/// Kartu satu lapangan di daftar Home (L-04).
///
/// Catatan adaptasi dari Figma: prototipe menggambar kartu 168×140 untuk
/// tata letak horizontal (dua kartu berdampingan). PRD v1.1 memutuskan
/// Home memakai daftar vertikal, jadi kartunya diubah jadi memanjang —
/// thumbnail di kiri, teks di kanan. Warna, radius, bayangan, dan ukuran
/// font tetap persis dari Figma.
class KartuLapangan extends StatelessWidget {
  final LapanganModel lapangan;
  final VoidCallback onTap;
  final bool difavoritkan;
  final VoidCallback onTapFavorit;

  const KartuLapangan({
    super.key,
    required this.lapangan,
    required this.onTap,
    required this.difavoritkan,
    required this.onTapFavorit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: AppColors.shadowKartu,
        ),
        // clipBehavior memastikan sudut thumbnail ikut membulat
        // mengikuti radius kartu.
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Thumbnail(lapangan: lapangan),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lapangan.nama,
                              style: AppTextStyles.namaLapangan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _TombolFavorit(
                            aktif: difavoritkan,
                            onTap: onTapFavorit,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lapangan.alamat,
                        style: AppTextStyles.metaLapangan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(_barisMeta(), style: AppTextStyles.metaLapangan),
                      const SizedBox(height: 6),
                      Text(
                        // Figma menulis "Rp 120k/jam" — versi ringkas.
                        '${Formatter.rupiahRingkas(lapangan.harga)}/jam',
                        style: AppTextStyles.harga,
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

  /// "⭐ 4.8 (12) · 0.8 km" — mengikuti gaya Figma.
  /// Lapangan yang belum punya rating menampilkan "Belum ada ulasan"
  /// supaya tidak muncul "⭐ 0.0" yang menyesatkan.
  String _barisMeta() {
    final bagian = <String>[];

    if (lapangan.jumlahRating > 0) {
      bagian.add(
        '⭐ ${lapangan.ratingRata2.toStringAsFixed(1)} (${lapangan.jumlahRating})',
      );
    } else {
      bagian.add('Belum ada ulasan');
    }

    if (lapangan.jarakKm != null) {
      // PRD L-04: jarak ditampilkan dengan 1 desimal.
      bagian.add('${lapangan.jarakKm!.toStringAsFixed(1)} km');
    }

    return bagian.join('  ·  ');
  }
}

/// Thumbnail kiri. Kalau `fotoURL` kosong (dan untuk data hasil seeding
/// memang kosong), tampilkan blok warna + emoji olahraga seperti di Figma.
class _Thumbnail extends StatelessWidget {
  final LapanganModel lapangan;

  const _Thumbnail({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    const lebar = 96.0;
    final olahragaUtama = lapangan.jenisOlahraga.isNotEmpty
        ? lapangan.jenisOlahraga.first
        : AppSports.futsal;

    if (lapangan.fotoURL.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: lapangan.fotoURL.first,
        width: lebar,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppColors.surfaceVariant),
        // Foto gagal dimuat bukan alasan untuk merusak kartu —
        // jatuh balik ke blok warna.
        errorWidget: (_, __, ___) =>
            _BlokWarna(olahraga: olahragaUtama, lebar: lebar),
      );
    }

    return _BlokWarna(olahraga: olahragaUtama, lebar: lebar);
  }
}

class _BlokWarna extends StatelessWidget {
  final String olahraga;
  final double lebar;

  const _BlokWarna({required this.olahraga, required this.lebar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lebar,
      color: _warnaOlahraga(olahraga),
      alignment: Alignment.center,
      child: Text(
        AppSports.ikonDari(olahraga),
        style: const TextStyle(fontSize: 28),
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

/// Ikon ♡ / ♥ — PRD AB-10.
class _TombolFavorit extends StatelessWidget {
  final bool aktif;
  final VoidCallback onTap;

  const _TombolFavorit({required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Area sentuh diperbesar lewat padding — ikon 18px terlalu kecil
      // untuk jari kalau tidak diberi ruang.
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          aktif ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: aktif ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
