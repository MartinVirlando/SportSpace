import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/chip_olahraga.dart';
import '../../../widgets/kartu_lapangan.dart';
import '../../auth/view/login_screen.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';
import 'detail_lapangan_screen.dart';

/// Halaman Home — PRD L-04.
///
/// ATURAN LAPISAN (CLAUDE.md): perhatikan daftar import di atas.
/// TIDAK ADA `cloud_firestore` di sini, dan tidak boleh pernah ada.
/// View hanya membaca state dari ViewModel dan menggambar.
///
/// Kalau kamu merasa butuh `FirebaseFirestore` di file view mana pun,
/// itu tandanya ada logika yang salah tempat — pindahkan ke Repository.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // `context.read` dipakai di initState karena kita hanya ingin
    // memanggil sebuah fungsi, bukan ikut membangun ulang widget.
    // `addPostFrameCallback` memastikan pemanggilan terjadi setelah
    // frame pertama selesai — memanggil notifyListeners saat widget
    // masih dibangun akan memicu error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().muatLapangan();
    });
  }

  @override
  Widget build(BuildContext context) {
    // `context.watch` membuat widget ini dibangun ulang setiap kali
    // ViewModel memanggil notifyListeners().
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 4),
            _KolomPencarian(
              onBerubah: context.read<HomeViewModel>().ubahKataKunci,
            ),
            const SizedBox(height: 10),
            BarisChipOlahraga(
              terpilih: vm.filterOlahraga,
              onPilih: context.read<HomeViewModel>().ubahFilterOlahraga,
            ),
            const SizedBox(height: 14),
            if (vm.pakaiLokasiDefault) const _SpandukLokasiDefault(),
            // Expanded supaya daftar mengisi sisa layar dan bisa digulir.
            Expanded(child: _Isi(vm: vm)),
          ],
        ),
      ),
    );
  }
}

/// Memilih apa yang digambar berdasarkan kondisi ViewModel.
///
/// Kelima kondisi ditangani eksplisit. Ini yang dimaksud "tidak boleh ada
/// layar putih polos" di Definisi Selesai PRD Bagian 12 poin 5.
class _Isi extends StatelessWidget {
  final HomeViewModel vm;

  const _Isi({required this.vm});

  @override
  Widget build(BuildContext context) {
    switch (vm.kondisi) {
      case KondisiHome.memuat:
        return const Center(child: CircularProgressIndicator());

      case KondisiHome.gagal:
        return _Pesan(
          ikon: Icons.error_outline,
          judul: 'Gagal memuat',
          keterangan: vm.pesanError ?? 'Terjadi kesalahan.',
          labelTombol: 'Coba Lagi',
          onTekan: () => context.read<HomeViewModel>().muatLapangan(),
        );

      case KondisiHome.lokasiDitolak:
        // PRD AB-03: arahkan ke pengaturan, JANGAN crash, dan sediakan
        // jalan keluar berupa tombol coba lagi.
        return _Pesan(
          ikon: Icons.location_off_outlined,
          judul: 'Lokasi belum aktif',
          keterangan: 'Aktifkan izin lokasi supaya kami bisa menghitung jarak '
              'lapangan dari posisimu.',
          labelTombol: 'Buka Pengaturan',
          onTekan: () async {
            await context.read<HomeViewModel>().bukaPengaturanLokasi();
            if (context.mounted) {
              await context.read<HomeViewModel>().muatLapangan();
            }
          },
        );

      case KondisiHome.kosong:
        return const _Pesan(
          ikon: Icons.search_off,
          judul: 'Belum ada lapangan',
          keterangan: 'Belum ada lapangan di sekitar kamu.',
        );

      case KondisiHome.berhasil:
        final daftar = vm.lapanganTampil;

        // Kondisi kosong kedua: data ADA, tapi filter/pencarian tidak
        // menyisakan apa pun. Pesannya harus beda dari kosong di atas,
        // karena solusinya beda — di sini pengguna tinggal mengubah filter.
        if (daftar.isEmpty) {
          return const _Pesan(
            ikon: Icons.filter_alt_off_outlined,
            judul: 'Tidak ada hasil',
            keterangan: 'Coba ubah kata kunci atau pilih olahraga lain.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<HomeViewModel>().muatLapangan(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.marginLayar,
              0,
              AppSizes.marginLayar,
              16,
            ),
            itemCount: daftar.length,
            itemBuilder: (context, i) {
              final lapangan = daftar[i];
              return KartuLapangan(
                lapangan: lapangan,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailLapanganScreen(
                      lapanganId: lapangan.lapanganId,
                    ),
                  ),
                ),
                // TODO(AB-10): baca status favorit dari FavoritViewModel
                difavoritkan: false,
                onTapFavorit: () {},
              );
            },
          ),
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final nama = context.watch<AuthViewModel>().user?.nama ?? '';

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        12,
        AppSizes.marginLayar,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $nama 👋', style: AppTextStyles.sambutan),
                const SizedBox(height: 2),
                const Text(
                  '📍 Tangerang Selatan',
                  style: AppTextStyles.lokasi,
                ),
              ],
            ),
          ),
          // Ikon lonceng + badge — PRD L-04, belum ada di Figma.
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                color: AppColors.textPrimary,
                // TODO(T-15): buka halaman Notifikasi (L-12)
                onPressed: () {},
              ),
              // TODO(T-15): tampilkan hanya kalau ada notifikasi belum dibaca
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Sementara di sini, bukan di PRD L-04 — Keluar sebenarnya milik
          // Profil (L-13, T-27) yang belum dibangun. Tanpa ini, menguji
          // BB-03/BB-04 berulang kali butuh hapus data app manual lewat adb.
          IconButton(
            icon: const Icon(Icons.logout),
            color: AppColors.textSecondary,
            tooltip: AppStrings.keluar,
            onPressed: () async {
              await context.read<AuthViewModel>().keluar();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _KolomPencarian extends StatelessWidget {
  final ValueChanged<String> onBerubah;

  const _KolomPencarian({required this.onBerubah});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginLayar),
      child: Container(
        height: AppSizes.tinggiPencarian,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusPencarian),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onBerubah,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Cari lapangan olahraga...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spanduk saat jarak dihitung dari lokasi default, bukan GPS (AB-03).
class _SpandukLokasiDefault extends StatelessWidget {
  const _SpandukLokasiDefault();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        0,
        AppSizes.marginLayar,
        12,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Memakai lokasi default. Aktifkan GPS untuk hasil lebih akurat.',
        style: AppTextStyles.metaLapangan,
      ),
    );
  }
}

/// Satu widget untuk semua kondisi kosong/gagal, supaya tampilannya seragam.
class _Pesan extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String keterangan;
  final String? labelTombol;
  final VoidCallback? onTekan;

  const _Pesan({
    required this.ikon,
    required this.judul,
    required this.keterangan,
    this.labelTombol,
    this.onTekan,
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
            Text(judul, style: AppTextStyles.judulSeksi),
            const SizedBox(height: 6),
            Text(
              keterangan,
              textAlign: TextAlign.center,
              style: AppTextStyles.lokasi,
            ),
            if (labelTombol != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onTekan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                  ),
                ),
                child: Text(labelTombol!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
