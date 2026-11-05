import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/formatter.dart';
import '../core/utils/harga.dart';
import '../models/lapangan_model.dart';

/// Harga per jam sebuah lapangan, dengan promo bila ada — PRD AB-18, v1.5
/// (T-65). Dipakai kartu Home (L-04), kartu ringkas Map (L-05), dan Detail
/// Lapangan (L-06) supaya tampilannya sama di semua tempat.
///
/// Tanpa promo (`diskonPersen == 0`): hanya "Rp 120k/jam", persis seperti
/// sebelum v1.5. Dengan promo: harga asli dicoret, harga setelah diskon di
/// sampingnya, dan label "Diskon X%".
class HargaLapangan extends StatelessWidget {
  final LapanganModel lapangan;

  /// `true` → "Rp 120k" (kartu); `false` → "Rp 120.000" (Detail).
  final bool ringkas;

  /// Gaya harga yang berlaku. Bawaan [AppTextStyles.harga].
  final TextStyle? gayaHarga;

  const HargaLapangan({
    super.key,
    required this.lapangan,
    this.ringkas = true,
    this.gayaHarga,
  });

  /// Pemisah harga dan satuan: "Rp 120k/jam" di kartu, "Rp 120.000 / jam"
  /// di Detail — sama seperti sebelum v1.5.
  String get _pemisah => ringkas ? '/' : ' / ';

  String _format(int nilai) =>
      ringkas ? Formatter.rupiahRingkas(nilai) : Formatter.rupiah(nilai);

  @override
  Widget build(BuildContext context) {
    final gaya = gayaHarga ?? AppTextStyles.harga;
    final persen = lapangan.diskonPersen;

    if (persen <= 0) {
      return Text(
        '${_format(lapangan.harga)}$_pemisah${AppStrings.satuanJam}',
        style: gaya,
      );
    }

    final hargaDiskon = hargaSetelahDiskon(lapangan.harga, persen);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: [
        Text(
          _format(lapangan.harga),
          style: AppTextStyles.metaLapangan(context).copyWith(
            decoration: TextDecoration.lineThrough,
          ),
        ),
        Text('${_format(hargaDiskon)}$_pemisah${AppStrings.satuanJam}', style: gaya),
        LabelDiskon(persen: persen),
      ],
    );
  }
}

/// Pil kecil "Diskon 20%". Merah muda supaya terbedakan dari label jenis dan
/// tingkat aktivitas yang hijau.
class LabelDiskon extends StatelessWidget {
  final int persen;

  const LabelDiskon({super.key, required this.persen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Text(
        AppStrings.labelDiskon(persen),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.red.shade700,
        ),
      ),
    );
  }
}
