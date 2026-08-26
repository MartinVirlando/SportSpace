import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/notifikasi_model.dart';
import '../../../repositories/notifikasi_repository.dart';
import '../../aktivitas/view/detail_aktivitas_screen.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../mitra/view/dashboard_mitra_screen.dart';
import '../viewmodel/notifikasi_viewmodel.dart';

/// Halaman Notifikasi — PRD L-12.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Menekan item menandai `sudahDibaca = true` lalu membuka objek terkait:
/// - `PERMINTAAN_*` (AB-06, `refId` = aktivitasId) → Detail Aktivitas
///   (L-09), sejak T-19.
/// - `BOOKING_BARU` (AB-04, penerimanya mitra) → Dashboard Mitra (L-14),
///   sejak T-25 — layar itu membaca ulang booking milik mitra lewat
///   `Stream`, jadi cukup dibuka tanpa membawa `refId`.
/// - `BOOKING_DIKONFIRMASI`/`BOOKING_DITOLAK` (penerimanya pemesan)
///   BELUM punya layar tujuan — tujuannya "Riwayat Pemesanan" di Profil
///   (L-13), baru dikerjakan T-27. Untuk sekarang item itu cuma ditandai
///   dibaca tanpa berpindah layar.
class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sama seperti home_screen.dart — jaga terhadap `user` yang sudah
    // null (mis. jendela logout) supaya tidak crash lewat `!`.
    final user = context.read<AuthViewModel>().user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final userId = user.userId;

    return ChangeNotifierProvider<NotifikasiViewModel>(
      create: (context) => NotifikasiViewModel(
        repository: context.read<NotifikasiRepository>(),
        userId: userId,
      ),
      child: const _NotifikasiBody(),
    );
  }
}

class _NotifikasiBody extends StatelessWidget {
  const _NotifikasiBody();

  Future<void> _bukaItem(BuildContext context, NotifikasiModel item) async {
    final vm = context.read<NotifikasiViewModel>();
    if (!item.sudahDibaca) {
      await vm.tandaiSudahDibaca(item.notifikasiId);
    }

    if (!context.mounted) return;
    if (item.tipe.startsWith('PERMINTAAN_')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailAktivitasScreen(aktivitasId: item.refId),
        ),
      );
    } else if (item.tipe == 'BOOKING_BARU') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DashboardMitraScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotifikasiViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title:
            const Text(AppStrings.notifikasi, style: AppTextStyles.judulSeksi),
      ),
      body: SafeArea(
        child: StreamBuilder<List<NotifikasiModel>>(
          stream: vm.streamNotifikasi,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _Pesan(
                ikon: Icons.error_outline,
                judul: AppStrings.errGagalMuat,
                keterangan:
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
              );
            }

            final daftar = snapshot.data ?? const [];
            if (daftar.isEmpty) {
              return const _Pesan(
                ikon: Icons.notifications_none,
                judul: AppStrings.kosongNotifikasi,
                keterangan: '',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: AppSizes.marginLayar,
              ),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = daftar[i];
                return _KartuNotifikasi(
                  item: item,
                  onTap: () => _bukaItem(context, item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _KartuNotifikasi extends StatelessWidget {
  final NotifikasiModel item;
  final VoidCallback onTap;

  const _KartuNotifikasi({required this.item, required this.onTap});

  IconData get _ikon {
    switch (item.tipe) {
      case 'PERMINTAAN_GABUNG':
        return Icons.person_add_outlined;
      case 'PERMINTAAN_DITERIMA':
        return Icons.check_circle_outline;
      case 'PERMINTAAN_DITOLAK':
        return Icons.cancel_outlined;
      case 'BOOKING_BARU':
      case 'BOOKING_DIKONFIRMASI':
      case 'BOOKING_DITOLAK':
        return Icons.event_note_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: AppColors.shadowKartu,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!item.sudahDibaca)
              Container(
                margin: const EdgeInsets.only(top: 4, right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 16),
            Icon(_ikon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: item.sudahDibaca
                        ? AppTextStyles.namaLapangan
                        : AppTextStyles.namaLapangan.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.pesan, style: AppTextStyles.metaLapangan),
                  const SizedBox(height: 4),
                  Text(
                    Formatter.tanggalDanJam(item.dibuatPada),
                    style: AppTextStyles.metaLapangan,
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
