import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/lencana.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/favorit_model.dart';
import '../viewmodel/profil_viewmodel.dart';

/// Seksi "Lencana" di Profil (L-13) — PRD AB-14, v1.4 (T-58).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Memakai TIGA stream yang sama dengan kotak statistik (AB-12) dan daftar
/// di bawahnya — `streamRiwayatBooking`, `streamAktivitasSaya`, dan
/// `streamDaftarFavorit` milik [ProfilViewModel]. Stream itu siaran
/// (broadcast), jadi pendengar tambahan ini tidak membuka listener Firestore
/// baru dan tidak menambah baca. Angka lencana pun ikut hidup, tanpa perlu
/// keluar-masuk akun (BB-57).
///
/// Aturan lencananya ada di `core/utils/lencana.dart` ([hitungLencana]).
/// Kondisi memuat dan gagal ditangani; kondisi "kosong" tidak ada karena
/// kelima lencana selalu tampil (yang belum diraih tampil redup).
class SeksiLencana extends StatelessWidget {
  final ProfilViewModel vm;

  const SeksiLencana({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: vm.streamRiwayatBooking,
      builder: (context, snapBooking) {
        return StreamBuilder<List<AktivitasBermainModel>>(
          stream: vm.streamAktivitasSaya,
          builder: (context, snapAktivitas) {
            return StreamBuilder<List<FavoritModel>>(
              stream: vm.streamDaftarFavorit,
              builder: (context, snapFavorit) {
                if (snapBooking.hasError ||
                    snapAktivitas.hasError ||
                    snapFavorit.hasError) {
                  return _Kerangka(
                    isi: Text(
                      AppStrings.errGagalMuatLencana,
                      style: AppTextStyles.metaLapangan(context),
                    ),
                  );
                }

                if (!snapBooking.hasData ||
                    !snapAktivitas.hasData ||
                    !snapFavorit.hasData) {
                  return const _Kerangka(
                    isi: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final daftar = hitungLencana(
                  jumlahBooking: snapBooking.data!.length,
                  jumlahAktivitas: snapAktivitas.data!.length,
                  jumlahFavorit: snapFavorit.data!.length,
                );
                final jumlahDiraih = daftar.where((l) => l.diraih).length;

                return _Kerangka(
                  keterangan: '$jumlahDiraih/${daftar.length}',
                  isi: LayoutBuilder(
                    builder: (context, batas) {
                      // Dua kolom: lebar tersedia dikurangi jarak, dibagi dua.
                      const jarak = 10.0;
                      final lebar = (batas.maxWidth - jarak) / 2;
                      return Wrap(
                        spacing: jarak,
                        runSpacing: jarak,
                        children: [
                          for (final lencana in daftar)
                            SizedBox(
                              width: lebar,
                              // Tinggi tetap supaya semua kartu sama tinggi, walau
                              // nama lencana ada yang satu dan ada yang dua baris.
                              height: 96,
                              child: _KartuLencana(lencana: lencana),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Judul seksi + isi, supaya kondisi memuat/gagal/berhasil punya bingkai sama.
class _Kerangka extends StatelessWidget {
  final String? keterangan;
  final Widget isi;

  const _Kerangka({this.keterangan, required this.isi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.judulLencana,
              style: AppTextStyles.judulSeksi(context),
            ),
            if (keterangan != null) ...[
              const SizedBox(width: 8),
              Text(keterangan!, style: AppTextStyles.metaLapangan(context)),
            ],
          ],
        ),
        const SizedBox(height: 10),
        isi,
      ],
    );
  }
}

class _KartuLencana extends StatelessWidget {
  final LencanaProfil lencana;

  const _KartuLencana({required this.lencana});

  @override
  Widget build(BuildContext context) {
    // Yang belum diraih tampil redup tapi tetap terbaca, lengkap dengan
    // syaratnya — supaya pengguna tahu apa yang harus dilakukan.
    return Opacity(
      opacity: lencana.diraih ? 1 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.warna.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: context.warna.shadowKartu,
          border: lencana.diraih
              ? Border.all(color: AppColors.primary, width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Text(lencana.ikon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                // min: supaya Column dipusatkan vertikal oleh Row, sama seperti
                // ikonnya, bukan menempel ke atas karena mengisi seluruh tinggi.
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lencana.nama,
                    style: AppTextStyles.namaLapangan(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lencana.syarat,
                    style: AppTextStyles.metaLapangan(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
