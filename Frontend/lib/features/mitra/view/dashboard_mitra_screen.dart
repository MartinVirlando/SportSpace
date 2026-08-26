import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/booking_model.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/lapangan_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/dashboard_mitra_viewmodel.dart';
import 'form_lapangan_screen.dart';

/// Halaman Dashboard Mitra — PRD L-14, T-25. BB-26 (konfirmasi), BB-27
/// (tolak, slot terbuka lagi).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Sampai T-27 (menu "Dashboard Mitra" di Profil) selesai, layar ini
/// dibuka lewat notifikasi `BOOKING_BARU` (lihat `notifikasi_screen.dart`)
/// — satu-satunya jalan masuk sementara, karena tab Profil (L-13) masih
/// placeholder `_SegeraHadir`.
///
/// Tombol "Tambah Lapangan" dan tap pada kartu lapangan membuka Form
/// Tambah/Edit Lapangan (L-15, T-26) — daftar lapangan di bawahnya
/// otomatis ikut berubah lewat `Stream`, jadi tidak perlu memuat ulang
/// manual sepulang dari form.
class DashboardMitraScreen extends StatelessWidget {
  const DashboardMitraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pemilikId = context.read<AuthViewModel>().user!.userId;

    return ChangeNotifierProvider<DashboardMitraViewModel>(
      create: (context) => DashboardMitraViewModel(
        lapanganRepository: context.read<LapanganRepository>(),
        bookingRepository: context.read<BookingRepository>(),
        pemilikId: pemilikId,
      ),
      child: const _DashboardMitraBody(),
    );
  }
}

class _DashboardMitraBody extends StatelessWidget {
  const _DashboardMitraBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardMitraViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.dashboardMitra,
          style: AppTextStyles.judulSeksi,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.lapanganSaya,
                  style: AppTextStyles.judulSeksi,
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FormLapanganScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(AppStrings.tambahLapangan),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<LapanganModel>>(
              stream: vm.streamLapanganMitra,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: AppTextStyles.metaLapangan,
                  );
                }
                final daftar = snapshot.data ?? const [];
                if (daftar.isEmpty) {
                  return const Text(
                    AppStrings.kosongLapanganMitra,
                    style: AppTextStyles.metaLapangan,
                  );
                }
                return Column(
                  children: [
                    for (final l in daftar) ...[
                      _KartuLapanganMitra(lapangan: l),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
            const Divider(height: 40),
            const Text(
              AppStrings.bookingMasuk,
              style: AppTextStyles.judulSeksi,
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<BookingModel>>(
              stream: vm.streamBookingMasuk,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: AppTextStyles.metaLapangan,
                  );
                }
                final daftar = snapshot.data ?? const [];
                if (daftar.isEmpty) {
                  return const Text(
                    AppStrings.kosongBookingMasuk,
                    style: AppTextStyles.metaLapangan,
                  );
                }
                return Column(
                  children: [
                    for (final b in daftar) ...[
                      _BarisBooking(booking: b),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuLapanganMitra extends StatelessWidget {
  final LapanganModel lapangan;

  const _KartuLapanganMitra({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FormLapanganScreen(lapangan: lapangan),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: AppColors.shadowKartu,
        ),
        child: Row(
          children: [
            Text(
              lapangan.jenisOlahraga.isEmpty
                  ? '🏟️'
                  : AppSports.ikonDari(lapangan.jenisOlahraga.first),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lapangan.nama, style: AppTextStyles.namaLapangan),
                  const SizedBox(height: 2),
                  Text(lapangan.alamat, style: AppTextStyles.metaLapangan),
                ],
              ),
            ),
            Text(
              '${Formatter.rupiahRingkas(lapangan.harga)}/jam',
              style: AppTextStyles.harga,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Satu baris booking masuk dengan tombol Konfirmasi/Tolak — PRD AB-08,
/// T-25, BB-26/BB-27.
///
/// StatefulWidget lokal (bukan lewat state proses bersama di ViewModel) —
/// pola yang sama seperti `_BarisPermintaan` di Detail Aktivitas, supaya
/// menekan Konfirmasi/Tolak di satu baris tidak mengunci baris lain.
class _BarisBooking extends StatefulWidget {
  final BookingModel booking;

  const _BarisBooking({required this.booking});

  @override
  State<_BarisBooking> createState() => _BarisBookingState();
}

class _BarisBookingState extends State<_BarisBooking> {
  bool _sedangProses = false;

  Future<void> _konfirmasi() async {
    setState(() => _sedangProses = true);
    final vm = context.read<DashboardMitraViewModel>();
    final error = await vm.konfirmasiBooking(widget.booking);
    if (!mounted) return;
    setState(() => _sedangProses = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? AppStrings.bookingDikonfirmasi)),
    );
  }

  Future<void> _tolak() async {
    setState(() => _sedangProses = true);
    final vm = context.read<DashboardMitraViewModel>();
    final error = await vm.tolakBooking(widget.booking);
    if (!mounted) return;
    setState(() => _sedangProses = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? AppStrings.bookingDitolak)),
    );
  }

  String get _labelStatus {
    switch (widget.booking.status) {
      case 'DIKONFIRMASI':
        return 'Dikonfirmasi';
      case 'DITOLAK':
        return 'Ditolak';
      case 'SELESAI':
        return 'Selesai';
      case 'DIBATALKAN':
        return 'Dibatalkan';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

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
              Expanded(
                child: Text(b.namaLapangan, style: AppTextStyles.namaLapangan),
              ),
              Text(Formatter.rupiah(b.totalHarga), style: AppTextStyles.harga),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${b.namaUser} · ${b.tanggal} · ${b.jamMulai}–${b.jamSelesai}',
            style: AppTextStyles.metaLapangan,
          ),
          const SizedBox(height: 10),
          if (b.status == 'MENUNGGU')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _sedangProses ? null : _tolak,
                    child: const Text(AppStrings.tolak),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sedangProses ? null : _konfirmasi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _sedangProses
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.konfirmasi),
                  ),
                ),
              ],
            )
          else
            Text(_labelStatus, style: AppTextStyles.metaLapangan),
        ],
      ),
    );
  }
}
