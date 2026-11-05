import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'chip_olahraga.dart';

/// Baris chip filter umum — daftar kode + peta label, gaya sama dengan
/// [BarisChipOlahraga]. Dipakai Cari Rekan (L-07) untuk filter jenis
/// aktivitas (T-54) dan tingkat kemampuan (T-55).
///
/// Tidak tahu apa-apa soal Firestore atau jenis datanya: ia hanya
/// menampilkan [daftarKode] dengan label dari [label], dan memberi tahu
/// pemanggil kode mana yang ditekan lewat [onPilih].
class BarisChipFilter extends StatelessWidget {
  final List<String> daftarKode;
  final Map<String, String> label;
  final String terpilih;
  final ValueChanged<String> onPilih;

  const BarisChipFilter({
    super.key,
    required this.daftarKode,
    required this.label,
    required this.terpilih,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginLayar),
        itemCount: daftarKode.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final kode = daftarKode[i];
          return ChipFilter(
            label: label[kode] ?? kode,
            aktif: kode == terpilih,
            onTap: () => onPilih(kode),
          );
        },
      ),
    );
  }
}
